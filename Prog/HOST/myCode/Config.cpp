/*
 * Config.cpp
 *
 *  Created on: Dec 7, 2020
 *      Author: Grzegorz
 */

#include "string.h"
#include "stdio.h"

#include "stm32f4xx_hal.h"

#include "main.h"
#include "UMain.h"
#include <Utils.h>
#include <Cpx.h>
#include <MdbCrc.h>
#include <myDef.h>
#include <Config.h>
#include <I2cDev.h>
#include <ErrorDef.h>

extern Config *config;
extern FramI2c *framMem;

//export do jezyka C

extern "C" const TcpInterfDef* getTcpDef() {
	static TcpInterfDef def;
	memcpy(&def, &config->data.R.B.tcp, sizeof(TcpInterfDef));
	return &def;
}

const char* getFrm1(int idx) {
	return "%.1f";
}

//-----------------------------------------------------------------------------------------
enum {

#include "host.itm"

};

const CpxDescr TcpInterfDscr[] = { //
		{ ctype : cpxBYTE, id:cfgB_tDhcp, ofs: offsetof(TcpInterfDef, dhcp), Name : "dhcp", size: sizeof(TcpInterfDef::dhcp) }, //
		{ ctype : cpxIP, id:cfgB_tIp, ofs: offsetof(TcpInterfDef, ip), Name : "ip", size: sizeof(TcpInterfDef::ip) }, //
		{ ctype : cpxIP, id:cfgB_tMask, ofs: offsetof(TcpInterfDef, mask), Name : "mask", size: sizeof(TcpInterfDef::mask) }, //
		{ ctype : cpxIP, id:cfgB_tGw, ofs: offsetof(TcpInterfDef, gw), Name : "gw", size: sizeof(TcpInterfDef::gw) }, //
		{ ctype : cpxIP, id:cfgB_tDns1, ofs: offsetof(TcpInterfDef, dns1), Name : "dns1", size: sizeof(TcpInterfDef::dns1) }, //
		{ ctype : cpxIP, id:cfgB_tDns2, ofs: offsetof(TcpInterfDef, dns2), Name : "dns2", size: sizeof(TcpInterfDef::dns2) }, //
		{ ctype : cpxNULL } };

const CpxDescr HostDefDscr[] = { //
		{ ctype : cpxBYTE, id:cfgH_liniaType, ofs: offsetof(HostCfg_Sz, liniaType), Name : "LiniaType", size: sizeof(HostCfg_Sz::liniaType) }, //
		{ ctype : cpxBYTE, id:cfgH_falownikType, ofs: offsetof(HostCfg_Sz, falownikType), Name : "FalownikType", size: sizeof(HostCfg_Sz::falownikType) }, //
		{ ctype : cpxINT, id:cfgH_radioChannel, ofs: offsetof(HostCfg_Sz, radioChannel), Name : "RadioChannel", size: sizeof(HostCfg_Sz::radioChannel) }, //
		{ ctype : cpxINT, id:cfgH_radioTxPower, ofs: offsetof(HostCfg_Sz, radioTxPower), Name : "RadioTxPower", size: sizeof(HostCfg_Sz::radioTxPower) }, //
		{ ctype : cpxFLOAT, id:cfgH_falowFreqLow, ofs: offsetof(HostCfg_Sz, falowFreqLow), Name : "FalowFreqLow", size: sizeof(HostCfg_Sz::falowFreqLow), exPtr :(const void*) getFrm1 }, //
		{ ctype : cpxFLOAT, id:cfgH_falowFreqHigh, ofs: offsetof(HostCfg_Sz, falowFreqHigh), Name : "FalowFreqHigh", size: sizeof(HostCfg_Sz::falowFreqHigh), exPtr :(const void*) getFrm1 }, //
		{ ctype : cpxFLOAT, id:cfgH_falowFreqSupport, ofs: offsetof(HostCfg_Sz, falowFreqSupport), Name : "FalowFreqSupport", size: sizeof(HostCfg_Sz::falowFreqSupport), exPtr :(const void*) getFrm1 }, //
		{ ctype : cpxBYTE, id:cfgH_pilotBeep, ofs: offsetof(HostCfg_Sz, pilotBeep), Name : "PilotBeep", size : sizeof(HostCfg_Sz::pilotBeep) }, //

		{ ctype : cpxNULL } };

const CpxDescr EmergencyDscr[] = { //
		{ ctype : cpxBOOL, id:cfgH_emerPilotOFF, ofs: offsetof(EmergCfg_Sz, emerPilotOFF), Name : "OffByPilot", size : sizeof(EmergCfg_Sz::emerPilotOFF) }, //
		{ ctype : cpxBOOL, id:cfgH_emerRolerOffAfterBeamUp, ofs: offsetof(EmergCfg_Sz, emerRolerOffAfterBeamUp), Name : "RolerOffAfterBeamUp", size : sizeof(EmergCfg_Sz::emerRolerOffAfterBeamUp) }, //
		{ ctype : cpxFLOAT, id:cfgH_delayRolerOffAfterBeamUp, ofs: offsetof(EmergCfg_Sz, delayRolerOffAfterBeamUp), Name : "DelayRolerOffAfterBeamUp", size : sizeof(EmergCfg_Sz::delayRolerOffAfterBeamUp), exPtr :(const void*) getFrm1 }, //
		{ ctype : cpxBOOL, id:cfgH_emerRolerOffAfterPCLost, ofs: offsetof(EmergCfg_Sz, emerRolerOffAfterPCLost), Name : "RolerOffAfterPCLost", size : sizeof(EmergCfg_Sz::emerRolerOffAfterPCLost) }, //
		{ ctype : cpxFLOAT, id:cfgH_delayRolerOffAfterPCLost, ofs: offsetof(EmergCfg_Sz, delayRolerOffAfterPCLost), Name : "DelayRolerOffAfterPCLost", size : sizeof(EmergCfg_Sz::delayRolerOffAfterPCLost), exPtr :(const void*) getFrm1 }, //
		{ ctype : cpxBOOL, id:cfgH_emerInverterOFFAfterConnLost, ofs: offsetof(EmergCfg_Sz, emerInverterOFFAfterConnLost), Name : "InverterOFFAfterConnLost", size : sizeof(EmergCfg_Sz::emerInverterOFFAfterConnLost) }, //
		{ ctype : cpxFLOAT, id:cfgH_delayInverterOFFAfterConnLost, ofs: offsetof(EmergCfg_Sz, delayInverterOFFAfterConnLost), Name : "DelayInverterOFFAfterConnLost", size : sizeof(EmergCfg_Sz::delayInverterOFFAfterConnLost), exPtr :(const void*) getFrm1 }, //

		{ ctype : cpxNULL } };

const CpxChildInfo TcpChild = {
		itemCnt : 1, itemSize : sizeof(TcpInterfDef), defs : TcpInterfDscr, flags:flagSHOWBR };
const CpxChildInfo HostChild = {
		itemCnt : 1, itemSize : sizeof(HostCfg_Sz), defs : HostDefDscr, flags:flagSHOWBR };
const CpxChildInfo EmergencyChild = {
		itemCnt : 1, itemSize : sizeof(EmergCfg_Sz), defs : EmergencyDscr, flags:flagSHOWBR };

const CpxDescr ConfigDscr[] = { //
		{ ctype : cpxSTR, id:cfgA_SN, ofs: offsetof(CfgRec, P.SerialNr), Name : "SerialNr", sizeof(CfgRec::P.SerialNr) }, //
		{ ctype : cpxSTR, id:cfgA_DEVID, ofs: offsetof(CfgRec, P.DevID), Name : "DevID", sizeof(CfgRec::P.DevID) }, //
		{ ctype : cpxCHILD, id:cfgA_TCP, ofs: offsetof(CfgRec, R.B.tcp), Name : "Tcp", size:0, exPtr: &TcpChild }, //
		{ ctype : cpxCHILD, id:cfgA_HostBase, ofs: offsetof(CfgRec, R.H), Name : "Host", size:0, exPtr: &HostChild }, //
		{ ctype : cpxCHILD, id:cfgA_Emerg, ofs: offsetof(CfgRec, R.E), Name : "Emerg", size:0, exPtr: &EmergencyChild }, //
		{ ctype : cpxNULL } };

Config::Config() {
	memset(&data, 0, sizeof(data));
}

uint32_t Config::getDevInfoSpecDevData() {
	uint32_t w = 0;
	w |= (data.R.H.liniaType) & 0x0f;
	w |= ((data.R.H.falownikType) & 0x07) << 4;
	return w;
}

void Config::getDataInfo(CfgDataInfo *info) {
	info->adr = &data;
	info->size = sizeof(data);
	info->dscr = ConfigDscr;
	info->histCfg = &data.H;
	info->baseCfg = &data.P;
}

#define  CFG_SIGN  0x2367A3B7

TStatus Config::CheckCfg() {
	if (data.P.Sign != CFG_SIGN || data.P.size != sizeof(data))
		return stCfgDataErr;

	if (!MdbCrc::Check(data.tab_b, sizeof(data)))
		return stCrcError;

	return stOK;
}

void Config::prepareToSave() {
	data.P.Sign = CFG_SIGN;
	data.P.size = sizeof(data);
	data.P.ver = 1;
	MdbCrc::Set(data.tab_b, sizeof(data) - 2);
}

void Config::Zero() {
	memset(&data, 0, sizeof(data));
	save();
}

void Config::Default() {
	memset(&data, 0, sizeof(data));
	strcpy(data.P.SerialNr, "W00001");
	data.R.B.tcp.dhcp = false;
	ipaddr_aton("192.168.254.161", &data.R.B.tcp.ip);
	ipaddr_aton("255.255.255.0", &data.R.B.tcp.mask);
	ipaddr_aton("192.168.254.254", &data.R.B.tcp.gw);
	ipaddr_aton("192.168.254.254", &data.R.B.tcp.dns1);
	ipaddr_aton("8.8.8.8", &data.R.B.tcp.dns2);
	save();
}

//------- CfgTcpInterf ---------------------------------------------------------
const char* Config::getDevSN() {
	return data.P.SerialNr;
}

const char* Config::getDevID() {
	return data.P.DevID;
}
void Config::getTcpDef(TcpCfgInterfDef *def) {
	def->dhcp = data.R.B.tcp.dhcp;
	def->ip = data.R.B.tcp.ip;
	def->mask = data.R.B.tcp.mask;
	def->gw = data.R.B.tcp.gw;
}
void Config::setTcpDef(const TcpCfgInterfDef *def) {
	data.R.B.tcp.dhcp = def->dhcp;
	data.R.B.tcp.ip = def->ip;
	data.R.B.tcp.mask = def->mask;
	data.R.B.tcp.gw = def->gw;
	save();
	delayReconfigNet(1000);

}
