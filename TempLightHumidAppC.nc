cofiguration TempLightHumidTLHC
{
}

implementation
{
	//General Components
	components TempLightHumidC as TLH;
	components Mainc, LedsC;
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	components new TimerMilliC() as Timer2;

	TLH.Boot -> Mainc;
	TLH.Leds -> LedsC;
	TLH.Timer0 -> Timer0;
	TLH.Timer1 -> Timer1;
	TLH.Timer2 -> Timer2;

	//Write to Serial Port
	components SerialPrintfC;

	//Light Component
	components new HamamatsuS10871TsrC() as LightSensor;
	TLH.ReadLight -> LightSensor;	

	//Temperature and Humidity components
	components new SensirionSht11C() as TempAndHumid;
	TLH.ReadHumid -> TempAndHumid.Humidity;
	TLH.ReadTemp -> TempAndHumid.Temperature; 

	//Radio
	components ActiveMessageC;
	components new AMSenderC(AM_RADIO);
	components new AMReceiverC(AM_RADIO)

	TLH.Packet -> AMSenderC;
	TLH.AMPacket -> AMSenderC;
	TLH.AMSend -> AMSenderC;
	TLH.AMControl -> ActiveMessageC;
	TLH.Receive -> AMReceiverC;
}

