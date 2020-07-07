#include <Timer.h>
#include <stdio.h>
#include <string.h>
#include "TempHumidLight.h"

module TempLightHumidC
{
	uses
	{
		//General Interfaces
		interface Boot;
		interface Leds;

		//Timer Interfaces
		interface Timer<TMilli> as Timer0; //For Light
		interface Timer<TMilli> as Timer1; //For Humidity
		interface Timer<TMilli> as Timer2; //For Temperature

		//Radio Interfaces
		interface Packet;
		interface AMPacket;
		interface AMSend;
		interface SplitControl as AMControl;
		interface Receive;

		//Read Temperature, Humidity, Light
		interface Read<uint16_t> as ReadLight;
		interface Read<uint16_t> as ReadHumid;
		interface Read<uint16_t> as ReadTemp;	
	}
}

implementation
{
	bool radioBusy = FALSE;
	message_t _packet;
	uint8_t tempBool, lightBool, humidBool;

	event void Boot.booted()
	{	
		call Timer0.startperiodic(1000);
		call Timer1.startperiodic(2000);
		call Timer2.startperiodic(3000);
		call AMControl.start();
		call Leds.led0On();
	}

	event void Timer0.fired()
	{
		if(call ReadLight.read() == SUCCESS)
			call Leds.led0Toggle();
	}

	event void Timer1.fired()
	{
		if(call ReadHumid.read() == SUCCESS)
			call Leds.led1Toggle();
	}

	event void Timer2.fired()
	{
		if(call ReadTemp.read() == SUCCESS)
			call Leds.led2Toggle();

		if (radioBusy == FALSE) 
		{
			//Create Packet
			MoteMsg_t* msg = call Packet.getPayload(& _packet, sizeof(MoteMsg_t));
			msg->NodeId = TOS_NODE_ID;
			msg->tempBool = tempBool;
			msg->lightBool = lightBool;
			msg->humidBool = humidBool;

			//Send Packet
			if (call AMSend.send(AM_BROADCAST_ADDR, &_packet, sizeof(MoteMsg_t)) == SUCCESS) 
			{
				radioBusy = TRUE;
			}
		}
	}

	event void ReadLight.readDone(error_t result, uint16_t val)
	{
		if(result == SUCCESS)
		{
			uint16_t light_intensity = (2.5*6250.0/4096.0)*val;
			printf("Light Intensity = %d", light_intensity);
			lightBool = 1;
		}

		else
		{
			printf("Problem Reading the Light Intensity");
			lightBool = 0;
		}
	}

	event void ReadHumid.readDone(error_t result, uint16_t val)
	{
		if(result == SUCCESS)
		{
			uint16_t humidity = -4.0 + 0.0405*val + (-2.8 * pow(10.0,-6))*(pow(val,2));
			printf("Current Humidity = %d", humidity);
			humidBool = 1;
		}

		else
		{
			printf("Problem Reading the Humidity");
			humid Bool = 0;
		}
	}

	event void ReadTemp.readDone(error_t result, uint16_t val)
	{
		if(result == SUCCESS)
		{
			uint16_t centigrade = -39.6 + .01*val;	
			printf("Current Temperature = %d", centigrade);	
			tempBool = 1;
		}

		else
		{
			printf("Problem Reading the Temperature");
			tempBool = 0;
		}
	}

	event void AMSend.sendDone(message_t *msg, error_t error) 
	{
		if (msg == &_packet) 
		{
			radioBusy = FALSE;
		}
	}

	event void AMControl.startDone(error_t error) 
	{
		if (error == SUCCESS) 
		{
			call Leds.led0On();
		}
		else 
		{
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t error) 
	{

	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		if (len == sizeof(MoteMsg_t)) 
		{
			MoteMsg_t * incomingpacket = (MoteMsg_t*) payload;

			uint8_t tempBool = incomingpacket->tempBool;
			uint8_t lightBool = incomingpacket->lightBool;
			uint8_t humidBool = incomingpacket->humidBool;

			if (humidBool == 1) 
			{
				call Leds.led1On();
			}
			
			else 
			{
				call Leds.led1Off();
			}

			if (tempBool == 1) 
			{
				call Leds.led2On();
			}
				
			else 
			{
				call Leds.led2Off();
			}
			
			if (lightBool == 1) 
			{
				call Leds.led0On();
			}
				
			else 
			{
				call Leds.led0Off();				}
			}
		}
		return msg;
	}
}

