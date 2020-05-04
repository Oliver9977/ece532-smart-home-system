# ece532-smart-home-system
Smart Home System For People With Disabilities

Below is a description of all the main files in our repository:

* Main_project: This is built on lab5 of the warm up demo
    * lab5_try2.sdk/test_net: Software that run on the processor
        * cJSON.c: JSON decoder
        * main.c: Most of the networking implementations are in there
        * Http_client.c: HTTP API interface as part of lwIP
    * lab5_try2.ipdefs: ip definitions
        * ip_repo_0/decision_main_block: decision making IP
        * ip_repo_0/myALSMaster_1.0: Master driver for ALS
        * ip_repo_0/mydecisionslave_2.0: slave interface for decision making IP
        * vga_ip_0: VGA IP
        * range_ip_0: range sensor driver IP
        * vivado-library-master_0: Official Pmod IP library

* vga_ip: Contains the drawing custom IP and the modified vga controller
    * src/vga_testing_wrapper.v: Debug logic for instantiating IP on its own
    * src/vga_block.v: Block diagram for entire VGA IP
    * src/vga.v: Modified vga controller from external source

Public repo : https://www.mygitserver.tk/siyuan/ece532-smart-home-system (Leave a message if access is needed)



