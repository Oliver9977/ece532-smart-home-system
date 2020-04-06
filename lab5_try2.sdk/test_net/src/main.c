/******************************************************************************
*
* Copyright (C) 2009 - 2017 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/
#define LWIP_ALTCP 1
//Standard library includes
#include <stdio.h>
#include <string.h>

//BSP includes for peripherals
#include "xparameters.h"
#include "netif/xadapter.h"
//#include "mytransmitter.h"

#include "platform.h"
#include "platform_config.h"
#if defined (__arm__) || defined(__aarch64__)
#include "xil_printf.h"
#endif
#include "xil_cache.h"

//LWIP include files
#include "lwip/ip_addr.h"
//#include "lwip/tcp.h"
#include "lwip/err.h"
#include "lwip/inet.h"
#if LWIP_IPV6==1
#include "lwip/ip.h"
#else
#if LWIP_DHCP==1
#include "lwip/dhcp.h"
#endif
#endif

#include "lwip/altcp.h"
#include "lwip/apps/http_client.h"

void lwip_init(); /* missing declaration in lwIP */

//TCP Network Params
#define SRC_MAC_ADDR {0x00, 0x0a, 0x35, 0x00, 0x01, 0x02}
#define SRC_IP4_ADDR "192.168.3.10"
#define IP4_NETMASK "255.255.255.0"
#define IP4_GATEWAY "192.168.3.1"
#define SRC_PORT 7

#define DEST_IP4_ADDR  "192.241.187.136"
#define DEST_IP4_ADDR_MSG "45.77.172.221"
//#define DEST_IP4_ADDR  "192.168.3.1"
#define DEST_IP6_ADDR "fe80::6600:6aff:fe71:fde6"
#define DEST_PORT 9090

#define PROXY_IP4_ADDR "192.168.56.1"

#define TCP_SEND_BUFSIZE 8

//volatile unsigned int* btnr = (unsigned int*) XPAR_AXI_GPIO_BTNR_BASEADDR;
//volatile unsigned int* leds = (unsigned int*) XPAR_AXI_GPIO_LED_BASEADDR;
//volatile unsigned int* leds_en = (unsigned int*) XPAR_AXI_GPIO_LED_EN_BASEADDR;
//volatile unsigned int* lights = (unsigned int*) XPAR_AXI_GPIO_LIGHTS_BASEADDR;
//volatile unsigned int* mydevice = (unsigned int*) XPAR_MYTRANSMITTER_0_S00_AXI_BASEADDR;
//volatile unsigned int* mydevice_int = (unsigned int*) MYTRANSMITTER_BASE;
//volatile u32 myals = (u32) XPAR_PMODALS_0_AXI_LITE_SPI_BASEADDR; //driver use u32
volatile unsigned int* ddr = (unsigned int*) XPAR_MIG7SERIES_0_BASEADDR;;
volatile unsigned int* pmod_master = (unsigned int*) XPAR_DESIGN_1_I_MYDECISIONMAKINGBLOCK_MYDECISIONSLAVE_0_S00_AXI_BASEADDR;
volatile unsigned int* pmod_master_2 = (unsigned int*) XPAR_DESIGN_1_I_MYDECISIONMAKINGBLOCK_MYDECISIONSLAVE_2_0_S00_AXI_BASEADDR;
unsigned int current_get_val = 0;
unsigned int seg_decoder(char disp);

//Function prototypes
#if LWIP_IPV6==1
void print_ip6(char *msg, ip_addr_t *ip);
#else
void print_ip(char *msg, ip_addr_t *ip);
void print_ip_settings(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw);
#endif
int setup_client_conn();
void tcp_fasttmr(void);
void tcp_slowtmr(void);

//Function prototypes for callbacks
//static err_t tcp_client_connected(void *arg, struct tcp_pcb *tpcb, err_t err);
//static err_t tcp_client_recv(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err);
//static err_t tcp_client_sent(void *arg, struct tcp_pcb *tpcb, u16_t len);
//static err_t tcp_client_send();
//static err_t tcp_client_get();
//static void tcp_client_err(void *arg, err_t err);
//static void tcp_client_close(struct tcp_pcb *pcb);
void http_finish (void *arg, httpc_result_t httpc_result, u32_t rx_content_len, u32_t srv_res, err_t err);
err_t http_get_result (void *arg, struct altcp_pcb *conn, struct pbuf *p, err_t err);
err_t http_header_done (httpc_state_t *connection, void *arg, struct pbuf *hdr, u16_t hdr_len, u32_t content_len);
int http_client_connect();
int http_client_notification();
volatile int http_finished = 1;

//DHCP global variables
#if LWIP_IPV6==0
#if LWIP_DHCP==1
extern volatile int dhcp_timoutcntr;
err_t dhcp_start(struct netif *netif);
#endif
#endif

//Networking global variables
extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;
static struct netif server_netif;
struct netif *app_netif;
char is_connected;

//Global tag
extern volatile int HexFlag;
extern volatile int MyIPFlag;

//Global IIC
//#include "xiic.h"
//static err_t start_tempsenser();
//XIic IICInstance;
//u8 IICRxMsg[2];
//u8 IICTxMsg[2];

//#include "xspi.h"
//static err_t start_acc();
//XSpi SPIInstance;
void SpiHandler(void *CallBackRef, u32 StatusEvent, unsigned int ByteCount);
volatile int spi_lock;
u8 SPIRxMsg[3];
u8 SPITxMsg[3];

//#include "PmodALS.h"
//PmodALS ALSInstance;

int test_number;

#include "cJSON.h"

int weather_decoder (int weather_id);

//temp sensor
//#include "PmodHYGRO.h"
//#include "sleep.h"
//#include "xil_cache.h"
//#include "xil_printf.h"
//#include "xparameters.h"

#define ACC_MASK 0x4
volatile int acc_event;
volatile int message_timer;
int acc_flag = 0x1;

int main()
{
	//Varibales for IP parameters
#if LWIP_IPV6==0
	ip_addr_t ipaddr, netmask, gw;
#endif

	//The mac address of the board. this should be unique per board
	unsigned char mac_ethernet_address[] = SRC_MAC_ADDR;

	//Network interface
	app_netif = &server_netif;

	//Initialize platform
	init_platform();

	//Defualt IP parameter values
#if LWIP_IPV6==0
#if LWIP_DHCP==1
    ipaddr.addr = 0;
	gw.addr = 0;
	netmask.addr = 0;
#else
	(void)inet_aton(SRC_IP4_ADDR, &ipaddr);
	(void)inet_aton(IP4_NETMASK, &netmask);
	(void)inet_aton(IP4_GATEWAY, &gw);
#endif	
#endif

	//LWIP initialization
	lwip_init();

	//Setup Network interface and add to netif_list
#if (LWIP_IPV6 == 0)
	if (!xemac_add(app_netif, &ipaddr, &netmask,
						&gw, mac_ethernet_address,
						PLATFORM_EMAC_BASEADDR)) {
		xil_printf("Error adding N/W interface\n");
		return -1;
	}
#else
	if (!xemac_add(app_netif, NULL, NULL, NULL, mac_ethernet_address,
						PLATFORM_EMAC_BASEADDR)) {
		xil_printf("Error adding N/W interface\n");
		return -1;
	}
	app_netif->ip6_autoconfig_enabled = 1;

	netif_create_ip6_linklocal_address(app_netif, 1);
	netif_ip6_addr_set_state(app_netif, 0, IP6_ADDR_VALID);

#endif
	netif_set_default(app_netif);

	//Now enable interrupts
	platform_enable_interrupts();

	//Specify that the network is up
	netif_set_up(app_netif);

#if (LWIP_IPV6 == 0)
#if (LWIP_DHCP==1)
	/* Create a new DHCP client for this interface.
	 * Note: you must call dhcp_fine_tmr() and dhcp_coarse_tmr() at
	 * the predefined regular intervals after starting the client.
	 */
	dhcp_start(app_netif);
	dhcp_timoutcntr = 24;

	while(((app_netif->ip_addr.addr) == 0) && (dhcp_timoutcntr > 0))
		xemacif_input(app_netif);

	if (dhcp_timoutcntr <= 0) {
		if ((app_netif->ip_addr.addr) == 0) {
			xil_printf("DHCP Timeout\n");
			xil_printf("Configuring default IP of %s\n", SRC_IP4_ADDR);
			(void)inet_aton(SRC_IP4_ADDR, &(app_netif->ip_addr));
			(void)inet_aton(IP4_NETMASK, &(app_netif->netmask));
			(void)inet_aton(IP4_GATEWAY, &(app_netif->gw));
		}
	}

	ipaddr.addr = app_netif->ip_addr.addr;
	gw.addr = app_netif->gw.addr;
	netmask.addr = app_netif->netmask.addr;
#endif
#endif

	//Print connection settings
#if (LWIP_IPV6 == 0)
	print_ip_settings(&ipaddr, &netmask, &gw);
#else
	print_ip6("Board IPv6 address ", &app_netif->ip6_addr[0].u_addr.ip6);
#endif


	//int btnr_active = 0;
	//unsigned int hex_cnt=0;

	//Setup connection
	//setup_client_conn();


	//Start IIC
	//start_tempsenser();

	//Start SPI
	//start_acc();
	//acc
	*(pmod_master + 5) = 1100;
	*(pmod_master + 2) = 0xffffffff;
	//light
	*(pmod_master_2 + 0x3) = 0x9;
	//ac
	*(pmod_master_2 + 0x0) = 25;
	*(pmod_master_2 + 0x1) = 30;
	*(pmod_master_2 + 0x2) = 20;
	//Start Pmod
	//ALS_begin(&ALSInstance,myals);
	*pmod_master=1;
	//xil_printf("Pmod 0x%x\n",*pmod_master);
	//*pmod_master=0;
	//*pmod_master=1;
	//DemoInitialize();
	//DemoRun();

	//Event loop
	while (1) {
		//Call tcp_tmr functions
		//Must be called regularly
		if (TcpFastTmrFlag) {
			tcp_fasttmr();
			TcpFastTmrFlag = 0;
		}
		if (TcpSlowTmrFlag) {
			tcp_slowtmr();
			TcpSlowTmrFlag = 0;
		}

		//Process data queued after interupt
		xemacif_input(app_netif);

		if (*(pmod_master + 4) & ACC_MASK){
			acc_event = 1;
			xil_printf("Got ACC INT\n");
			*(pmod_master + 3) = 0xffffffff;
			*(pmod_master + 3) = 0x0;
		}

		if (message_timer > 0){
			message_timer = message_timer -1;
		}

		if (http_finished){
			http_client_notification();
		}

		//ADD CODE HERE to be repeated constantly 
		// Note - should be non-blocking
		// Note - can check is_connected global var to see if connection open
		//*lights = 0b11111001;

		//Add hex decoder here and manually enable/disable each segment

//		if (HexFlag){
//			//xil_printf("current_get_val = 0x%x\n",current_get_val);
//			*leds_en = ~(1<<hex_cnt);
//			unsigned int shft = hex_cnt*4;
//			*leds = seg_decoder( (current_get_val & (0xF<<shft)) >> shft );
//			//xil_printf("num = 0x%x\n",( (current_get_val & (0xF<<shft)) >> shft) );
//			if (hex_cnt == 7)
//			    hex_cnt = 0;
//			else hex_cnt ++;
//			HexFlag = 0;
//		}
		
		//*pmod_master=1;

		//xil_printf("testnumber 0x%x",test_number);

		//Only send get request once and wait for button to be released
//		if (*btnr & !btnr_active){
//			if(is_connected){
//				tcp_client_get();
//				btnr_active = 1;
//			}
//		} else if (btnr_active & !(*btnr)){
//			btnr_active = 0;
//		}
//
//		if (MyIPFlag){
//			if(is_connected){
//				xil_printf("mydevice = 0x%x\n",*mydevice);
//				tcp_client_send();
//			}
//			MyIPFlag = 0;
//		}


		//IIC

		//XIicStats temp;
		//XIic_GetStats(&IICInstance,&temp);
		//xil_printf("TxErrors = %d\n",temp.TxErrors);
		//xil_printf("ArbitrationLost = %d\n",temp.ArbitrationLost);
		//xil_printf("RepeatedStarts = %d\n",temp.RepeatedStarts);
		//xil_printf("RecvInterrupts = %d\n",temp.RecvInterrupts);
		//xil_printf("IicInterrupts = %d\n",temp.IicInterrupts);
		//xil_printf("SendBytes = %d\n",temp.SendBytes);
		//XIic_MasterRecv(&IICInstance,&IICRxMsg,1);
		//test
//		err_t test = XIic_MasterRecv(&IICInstance,IICRxMsg,2);
//		if (test == XST_IIC_BUS_BUSY){
//			xil_printf("IIC Busy");
//		}
//		xil_printf("IICRxMsg = %02x %02x\n",IICRxMsg[0],IICRxMsg[1]);
//		u32 temp =  IICRxMsg[0];
//		*(pmod_master + 7) = ((temp << 8) | IICRxMsg[1]);
//		xil_printf("IICRxMsg = %x\n",*(pmod_master + 7));

		//SPI
		//spi_lock = 1;
		//SPITxMsg[0] = 0x0B;
		//SPITxMsg[1] = 0x0A;
		//SPITxMsg[2] = 0x0A;
		//XSpi_Transfer(&SPIInstance,SPITxMsg,SPIRxMsg,2);
		//while (spi_lock == 1){
			//wait for it to finish
		//}
		//xil_printf("SPIRxMsg = %x%x%x\n",SPIRxMsg[2],SPIRxMsg[1],SPIRxMsg[0]);

		//u8 result = ALS_read(&ALSInstance);
		//xil_printf("Pmod 0x%x\n",result);
		//END OF ADDED CODE
	}
	//Never reached
	cleanup_platform();

	return 0;
}


unsigned int seg_decoder(char disp){
    unsigned int seg;
    switch (disp) {
        case 0b0000:
            seg = 0b11000000;
            break;
        case 0b0001:
            seg = 0b11111001;
            break;
        case 0b0010:
            seg = 0b10100100;
            break;
        case 0b0011:
            seg = 0b10110000;
            break;
        case 0b0100:
            seg = 0b10011001;
            break;
        case 0b0101:
            seg = 0b10010010;
            break;
        case 0b0110:
            seg = 0b10000010;
            break;
        case 0b0111:
            seg = 0b11111000;
            break;
        
        case 0b1000:
            seg = 0b10000000;
            break;
        case 0b1001:
            seg = 0b10010000;
            break;
        case 0b1010:
            seg = 0b10100000;
            break;
        case 0b1011:
            seg = 0b10000011;
            break;
        case 0b1100:
            seg = 0b11000110;
            break;
        case 0b1101:
            seg = 0b10100001;
            break;
        case 0b1110:
            seg = 0b10000110;
            break;
        case 0b1111:
            seg = 0b10001110;
            break;
        
        default: seg = 0b11111111;
        // default statements
    }
    return seg;
}

#if LWIP_IPV6==1
void print_ip6(char *msg, ip_addr_t *ip)
{
	print(msg);
	xil_printf(" %x:%x:%x:%x:%x:%x:%x:%x\n",
			IP6_ADDR_BLOCK1(&ip->u_addr.ip6),
			IP6_ADDR_BLOCK2(&ip->u_addr.ip6),
			IP6_ADDR_BLOCK3(&ip->u_addr.ip6),
			IP6_ADDR_BLOCK4(&ip->u_addr.ip6),
			IP6_ADDR_BLOCK5(&ip->u_addr.ip6),
			IP6_ADDR_BLOCK6(&ip->u_addr.ip6),
			IP6_ADDR_BLOCK7(&ip->u_addr.ip6),
			IP6_ADDR_BLOCK8(&ip->u_addr.ip6));

}
#else
void print_ip(char *msg, ip_addr_t *ip)
{
	print(msg);
	xil_printf("%d.%d.%d.%d\n", ip4_addr1(ip), ip4_addr2(ip),
			ip4_addr3(ip), ip4_addr4(ip));
}

void print_ip_settings(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw)
{

	print_ip("Board IP: ", ip);
	print_ip("Netmask : ", mask);
	print_ip("Gateway : ", gw);
}
#endif


int http_client_connect(){
	http_finished = 0;
	err_t err;
	ip_addr_t remote_addr,proxy_addr;
	httpc_connection_t *setting = calloc(1,sizeof(httpc_connection_t));
	httpc_state_t* http_state;

	setting->result_fn = http_finish;
	setting->headers_done_fn = http_header_done;
	setting->altcp_allocator = NULL;

	err = inet_aton(PROXY_IP4_ADDR, &proxy_addr);
	if (!err) {
		xil_printf("Invalid Proxy Server IP address: %d\n", err);
		return -1;
	}

	setting->proxy_addr = proxy_addr;
	setting->proxy_port = 10809;
	setting->use_proxy = 1;

	xil_printf("Setting up client connection\n");

	#if LWIP_IPV6==1
		remote_addr.type = IPADDR_TYPE_V6;
		err = inet6_aton(DEST_IP6_ADDR, &remote_addr);
	#else
		err = inet_aton(DEST_IP4_ADDR, &remote_addr);
	#endif

	if (!err) {
		xil_printf("Invalid Server IP address: %d\n", err);
		return -1;
	}
	err = httpc_get_file(&remote_addr, 80, "/data/2.5/weather?q=Toronto&appid=1641fa42051392ad3c0e62768c6effab&units=metric", setting, http_get_result, NULL, &http_state);
	xil_printf("Debug: acc_event %d , message_timer %d\n",acc_event,message_timer);

	return 0;
}

int http_client_notification(){
	xil_printf("Debug: message_timer %d acc_event %d\n",acc_event,message_timer);

	if (acc_event == 0){
		//nothing critical
		http_client_connect();
		return 0;//pypass
	}else if ((message_timer == 0) && (acc_event == 1)){
		xil_printf("Need to send notification\n");
		message_timer = 0xffff; //start timer
	}else{
		//waiting for timer
		return 0;//pypass
	}

	http_finished = 0;
	err_t err;
	ip_addr_t remote_addr,proxy_addr;
	httpc_connection_t *setting = calloc(1,sizeof(httpc_connection_t));
	httpc_state_t* http_state;

	setting->result_fn = http_finish;
	setting->headers_done_fn = http_header_done;
	setting->altcp_allocator = NULL;

	err = inet_aton(PROXY_IP4_ADDR, &proxy_addr);
	if (!err) {
		xil_printf("Invalid Proxy Server IP address: %d\n", err);
		return -1;
	}

	setting->proxy_addr = proxy_addr;
	setting->proxy_port = 10809;
	setting->use_proxy = 1;

	xil_printf("Setting up client connection\n");

	#if LWIP_IPV6==1
		remote_addr.type = IPADDR_TYPE_V6;
		err = inet6_aton(DEST_IP6_ADDR, &remote_addr);
	#else
		err = inet_aton(DEST_IP4_ADDR_MSG, &remote_addr);
	#endif

	if (!err) {
		xil_printf("Invalid Server IP address: %d\n", err);
		return -1;
	}
	err = httpc_get_file(&remote_addr, 8080, "/http-api.php?action=sendsms&user=pon7jwus&password=e4zT5zZp&from=test&to=14372313461&text=HelpMe", setting, http_get_result, &acc_flag, &http_state);

	return 0;
}


void http_finish (void *arg, httpc_result_t httpc_result, u32_t rx_content_len, u32_t srv_res, err_t err){
	xil_printf("Http Finished with %d\n",httpc_result);
	if (httpc_result !=0){
		http_finished = 1;
	}
}

err_t http_header_done (httpc_state_t *connection, void *arg, struct pbuf *hdr, u16_t hdr_len, u32_t content_len){

	return ERR_OK;
}

err_t http_get_result (void *arg, struct altcp_pcb *conn, struct pbuf *p, err_t err){
	if (arg != NULL && *((int*)arg) == acc_flag){
		xil_printf("Got response from messager\n");
		acc_event = 0;
		http_finished = 1;
		return ERR_OK;
	}

	cJSON *json = NULL;
	cJSON *weather = NULL;
	cJSON *weather_id = NULL;
	cJSON *main_s = NULL;
	cJSON *temp = NULL;
	xil_printf("Http result ready ....\n");
	xil_printf("Total len %d\n",p->tot_len);
	xil_printf("This buffer %d\n",p->len);
	//enforce null
	((char*) (p->payload)) [(p->len)] = 0x00;
	xil_printf("Message %s\n",p->payload); //format string attack .....
	json = cJSON_Parse(p->payload);
	if (json == NULL){
		xil_printf("Error: Cannot parse the data.\n");
	}

	weather = cJSON_GetObjectItemCaseSensitive(json, "weather");
	if (weather == NULL){
		xil_printf("Error: Unknown data structure.\n");
	}
	//xil_printf("Is array: %d\n",cJSON_IsArray(weather));
	weather_id = cJSON_GetObjectItemCaseSensitive(weather->child,"id");
	if (weather_id == NULL){
		xil_printf("Error: Unknown data structure. Can't find weather id\n");
	}
	if (!cJSON_IsNumber(weather_id)){
		xil_printf("Error: Unknown data structure. Id not a number. \n");
	}
	xil_printf("Test result: %d\n",weather_id->valueint);
	*(pmod_master + 0x1) = weather_decoder(weather_id->valueint);
	main_s = cJSON_GetObjectItemCaseSensitive(json, "main");
	if (main_s == NULL){
		xil_printf("Error: Unknown data structure. Can't find main\n");
	}

	temp = cJSON_GetObjectItemCaseSensitive(main_s, "temp");
	if (temp == NULL){
		xil_printf("Error: Unknown data structure. Can't find temp\n");
	}
	if (!cJSON_IsNumber(temp)){
		xil_printf("Error: Unknown data structure. temp not a number. \n");
	}
	*(pmod_master_2 + 0x4) = temp->valueint;

	cJSON_Delete(json);
	http_finished = 1;
	return ERR_OK;
}

int weather_decoder (int weather_id){
	int icon_id;

	switch (weather_id){
		case 800: icon_id = 1; break;
		case 801: icon_id = 2; break;
		case 802: icon_id = 3; break;
		case 803:
		case 804: icon_id = 4; break;

		case 500:
		case 501:
		case 502:
		case 503:
		case 504: icon_id = 10; break;

		case 300:
		case 301:
		case 302:
		case 310:
		case 311:
		case 312:
		case 313:
		case 314:
		case 321: icon_id = 9; break;

		case 200:
		case 201:
		case 202:
		case 210:
		case 211:
		case 212:
		case 213:
		case 214:
		case 221: icon_id = 11; break;

		default: icon_id = 0;

	}

	return icon_id;
}

//
//int setup_client_conn()
//{
//	struct altcp_pcb *pcb;
//	err_t err;
//	ip_addr_t remote_addr;
//
//	xil_printf("Setting up client connection\n");
//
//#if LWIP_IPV6==1
//	remote_addr.type = IPADDR_TYPE_V6;
//	err = inet6_aton(DEST_IP6_ADDR, &remote_addr);
//#else
//	err = inet_aton(DEST_IP4_ADDR, &remote_addr);
//#endif
//
//	if (!err) {
//		xil_printf("Invalid Server IP address: %d\n", err);
//		return -1;
//	}
//
//	//Create new TCP PCB structure
//
//	altcp_allocator_t myallo;
//	pcb = altcp_new_ip_type(&myallo,IPADDR_TYPE_ANY);
//	if (!pcb) {
//		xil_printf("Error creating PCB. Out of Memory\n");
//		return -1;
//	}
//
//	//Bind to specified @port
//	err = altcp_bind(pcb, IP_ANY_TYPE, SRC_PORT);
//	if (err != ERR_OK) {
//		xil_printf("Unable to bind to port %d: err = %d\n", SRC_PORT, err);
//		return -2;
//	}
//
//	//Connect to remote server (with callback on connection established)
//	err = altcp_connect(pcb, &remote_addr, DEST_PORT, tcp_client_connected);
//	if (err) {
//		xil_printf("Error on tcp_connect: %d\n", err);
//		tcp_client_close(pcb);
//		return -1;
//	}
//
//	is_connected = 0;
//
//	xil_printf("Waiting for server to accept connection\n");
//
//	return 0;
//}
//
//static void tcp_client_close(struct tcp_pcb *pcb)
//{
//	err_t err;
//
//	xil_printf("Closing Client Connection\n");
//
//	if (pcb != NULL) {
//		tcp_sent(pcb, NULL);
//		tcp_recv(pcb,NULL);
//		tcp_err(pcb, NULL);
//		err = tcp_close(pcb);
//		if (err != ERR_OK) {
//			/* Free memory with abort */
//			tcp_abort(pcb);
//		}
//	}
//}
//
//static err_t tcp_client_connected(void *arg, struct tcp_pcb *tpcb, err_t err)
//{
//	if (err != ERR_OK) {
//		tcp_client_close(tpcb);
//		xil_printf("Connection error\n");
//		return err;
//	}
//
//	xil_printf("Connection to server established\n");
//
//	//Store state (for callbacks)
//	c_pcb = tpcb;
//	is_connected = 1;
//
//	//Set callback values & functions
//	tcp_arg(c_pcb, NULL);
//	tcp_recv(c_pcb, tcp_client_recv);
//	tcp_sent(c_pcb, tcp_client_sent);
//	tcp_err(c_pcb, tcp_client_err);
//
//
//
//	//ADD CODE HERE to do when connection established
//
//	//Just send a single packet
//	u8_t apiflags = TCP_WRITE_FLAG_COPY | TCP_WRITE_FLAG_MORE;
//	char send_buf[TCP_SEND_BUFSIZE];
//	u32_t i;
//	send_buf[0] = 'P';
//	send_buf[1] = 'O';
//	send_buf[2] = 'S';
//	send_buf[3] = 'T';
//
//	for(i = 4; i < TCP_SEND_BUFSIZE-1; i = i + 1)
//	{
//		send_buf[i] = i+'a';
//	}
//	send_buf[TCP_SEND_BUFSIZE-1] = '\n';
//
//	//Loop until enough room in buffer (should be right away)
//	while (tcp_sndbuf(c_pcb) < TCP_SEND_BUFSIZE);
//
//	//Enqueue some data to send
//	err = tcp_write(c_pcb, send_buf, TCP_SEND_BUFSIZE, apiflags);
//	if (err != ERR_OK) {
//		xil_printf("TCP client: Error on tcp_write: %d\n", err);
//		return err;
//	}
//
//	//send the data packet
//	err = tcp_output(c_pcb);
//	if (err != ERR_OK) {
//		xil_printf("TCP client: Error on tcp_output: %d\n",err);
//		return err;
//	}
//
//	xil_printf("Packet data sent\n");
//
//	//END OF ADDED CODE
//
//
//
//	return ERR_OK;
//}
//
////Send the word stored in mydevice using a POST request
//static err_t tcp_client_send()
//{
//
//	err_t err = ERR_OK;
//	//Just send a single packet
//	u8_t apiflags = TCP_WRITE_FLAG_COPY | TCP_WRITE_FLAG_MORE;
//	char send_buf[TCP_SEND_BUFSIZE];
//	send_buf[0] = 'P';
//	send_buf[1] = 'O';
//	send_buf[2] = 'S';
//	send_buf[3] = 'T';
//	unsigned int current_word = *mydevice;
//	//Bytes must be sent backwards
//	send_buf[7] = (char) (current_word & 0x000000FF);
//	send_buf[6] = (char)((current_word & 0x0000FF00) >> 8);
//	send_buf[5] = (char)((current_word & 0x00FF0000) >> 16);
//	send_buf[4] = (char)((current_word & 0xFF000000) >> 24);
//
//	//For debug
//	/*
//	for(int i = 0; i < TCP_SEND_BUFSIZE; i++){
//		xil_printf("0x%x ", send_buf[i]);
//	}
//	xil_printf("\n");
//	*/
//
//	//send_buf[TCP_SEND_BUFSIZE-1] = '\n';
//
//	//Loop until enough room in buffer (should be right away)
//	while (tcp_sndbuf(c_pcb) < TCP_SEND_BUFSIZE);
//
//	//Enqueue some data to send
//	err = tcp_write(c_pcb, send_buf, TCP_SEND_BUFSIZE, apiflags);
//	if (err != ERR_OK) {
//		xil_printf("TCP client: Error on tcp_write: %d\n", err);
//		return err;
//	}
//
//	//send the data packet
//	err = tcp_output(c_pcb);
//	if (err != ERR_OK) {
//		xil_printf("TCP client: Error on tcp_output: %d\n",err);
//		return err;
//	}
//
//	xil_printf("Packet data sent\n");
//
//	return ERR_OK;
//}
//
////Send a GET request with no other data in the packet
//static err_t tcp_client_get()
//{
//
//	err_t err = ERR_OK;
//	//Just send a single packet
//	u8_t apiflags = TCP_WRITE_FLAG_COPY | TCP_WRITE_FLAG_MORE;
//	char send_buf[3];
//	send_buf[0] = 'G';
//	send_buf[1] = 'E';
//	send_buf[2] = 'T';
//
//	//Loop until enough room in buffer (should be right away)
//	while (tcp_sndbuf(c_pcb) < 3);
//
//	//Enqueue some data to send
//	err = tcp_write(c_pcb, send_buf, 3, apiflags);
//	if (err != ERR_OK) {
//		xil_printf("TCP client: Error on tcp_write: %d\n", err);
//		return err;
//	}
//
//	//send the data packet
//	err = tcp_output(c_pcb);
//	if (err != ERR_OK) {
//		xil_printf("TCP client: Error on tcp_output: %d\n",err);
//		return err;
//	}
//
//	xil_printf("Get packet sent\n");
//
//	return ERR_OK;
//}
//
//static err_t tcp_client_recv(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err)
//{
//	//If no data, connection closed
//	if (!p) {
//		xil_printf("No data received\n");
//		//return 0;
//		tcp_client_close(tpcb);
//		return ERR_OK;
//	}
//
//
//
//	//ADD CODE HERE to do on packet reception
//
//	//Print message
//	xil_printf("Packet response received, %d bytes\n", p->tot_len);
//
//	//Print packet contents to terminal
//	char* packet_data = (char*) malloc(p->tot_len);
//	pbuf_copy_partial(p, packet_data, p->tot_len, 0); //Note - inefficient way to access packet data
//	u32_t i;
//
//	if (packet_data[0] != 'A' && packet_data[1] != 'C' && packet_data[2] != 'K'){
//		current_get_val = 0;
//		xil_printf("p->tot_len: %d",p->tot_len);
//		for(i = 0; i < p->tot_len; i = i + 1){
//			//We may have to switch the order for this
//			xil_printf("packet_data[i]: 0x%x\n",packet_data[i]);
//			current_get_val = current_get_val << 8;
//			current_get_val |= (packet_data[i] & 0xFF);
//			putchar(packet_data[i]);
//		}
//		xil_printf("current_get_val = 0x%x\n",current_get_val);
//	}
//
//
//	//END OF ADDED CODE
//
//
//
//	//Indicate done processing
//	tcp_recved(tpcb, p->tot_len);
//
//	//Free the received pbuf
//	pbuf_free(p);
//
//	return 0;
//}
//
//static err_t tcp_client_sent(void *arg, struct tcp_pcb *tpcb, u16_t len)
//{
//
//
//	//ADD CODE HERE to do on packet acknowledged
//
//	//Print message
//	xil_printf("Packet sent successfully, %d bytes\n", len);
//
//	//END OF ADDED CODE
//
//
//
//	return 0;
//}
//
//static void tcp_client_err(void *arg, err_t err)
//{
//	LWIP_UNUSED_ARG(err);
//	tcp_client_close(c_pcb);
//	c_pcb = NULL;
//	xil_printf("TCP connection aborted\n");
//}
//

//static void XIic_testRecvHandler(void *CallBackRef, int ByteCount)
//{
//	(void) ByteCount;
//	(void) CallBackRef;
//	if (ByteCount !=0){
//		XIic_MasterRecv(&IICInstance,IICRxMsg,ByteCount);
//		xil_printf("ByteCount %d\n",ByteCount);
//	}
//
//}
//
//static void XIic_testSendHandler(void *CallBackRef, int ByteCount)
//{
//	(void) ByteCount;
//	(void) CallBackRef;
//	XIic_MasterSend(&IICInstance,IICTxMsg,ByteCount);
//	xil_printf("IICTxMsg %x\n",IICTxMsg);
//
//}
//
//static void XIic_testStatusHandler(void *CallBackRef, int ErrorCode)
//{
//	(void) ErrorCode;
//	(void) CallBackRef;
//	xil_printf("Error code %d\n",ErrorCode);
//}


//test section for IIC
//static err_t start_tempsenser(){
//	int err;
//	err = XIic_Initialize(&IICInstance,XPAR_AXI_IIC_0_DEVICE_ID);
//	if (err != XST_SUCCESS){
//		xil_printf("IIC Init Failed ...\n");
//		return -1;
//	}
//
//	//link interface with device
//	XIic_SetAddress(&IICInstance,XII_ADDR_TO_SEND_TYPE,0x4B);
//
//	//set handler
//	XIic_SetRecvHandler(&IICInstance,NULL,XIic_testRecvHandler);
//	XIic_SetSendHandler(&IICInstance,NULL,XIic_testSendHandler);
//	XIic_SetStatusHandler(&IICInstance,NULL,XIic_testStatusHandler);
//
//	//call start, always return success
//	XIic_Start(&IICInstance);
//	//XIic_IntrGlobalDisable(IICInstance.BaseAddress);
//
//	return ERR_OK;
//
//}

//test section for SPI
//static err_t start_acc(){
//	int err;
//	err = ALS_SPIInit(&SPIInstance);
//	if (err != XST_SUCCESS){
//		xil_printf("IIC Init Failed ...\n");
//		return -1;
//	}

//	err = XSpi_Initialize(&SPIInstance,XPAR_AXI_QUAD_SPI_0_DEVICE_ID);
//	if (err != XST_SUCCESS){
//		xil_printf("IIC Init Failed ...\n");
//		return -1;
//	}

//	XSpi_SetSlaveSelect(&SPIInstance,0x1);
//	err = XSpi_SetOptions(&SPIInstance, XSP_MASTER_OPTION | XSP_MANUAL_SSELECT_OPTION);
//	if (err != XST_SUCCESS){
//			xil_printf("XSpi SetOptions Failed ...\n");
//			return -2;
//	}


//	XSpi_SetStatusHandler(&SPIInstance,&SPIInstance,SpiHandler);

//	err = XSpi_Start(&SPIInstance);
//	if (err != XST_SUCCESS){
//		xil_printf("XSpi Start Failed ...\n");
//		return -3;
//	}

//	err = XSpi_SelfTest(&SPIInstance);
//	if (err != XST_SUCCESS){
//		xil_printf("XSpi SelfTest Failed ...\n");
//		return -1;
//	}

//	return ERR_OK;

//}

//void SpiHandler(void *CallBackRef, u32 StatusEvent, unsigned int ByteCount)
//{
//	if (StatusEvent == XST_SPI_TRANSFER_DONE){
//		spi_lock = 0;
//		xil_printf("XST_SPI_TRANSFER_DONE: %d\n",ByteCount);
//	}
//}
