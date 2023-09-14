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

extern Config *config;
extern FramI2c *framMem;

//export do jezyka C

extern "C" const TcpInterfDef* getTcpDef() {
	return &config->data.R.E.tcp;

}

//-----------------------------------------------------------------------------------------
enum {

#include "kp.itm"

};

const char* getFrm1(int idx) {
	return "%.1f";
}

const CpxDescr KalibrZeroDscr[] = { //
		{ ctype : cpxFLOAT, id:cfgX_xInpVal_Open, ofs: offsetof(TKalibrZero, InpVal_Open), Name : "InpVal_Open", size: sizeof(TKalibrZero::InpVal_Open) }, //
		{ ctype : cpxFLOAT, id:cfgX_xInpVal_Close, ofs: offsetof(TKalibrZero, InpVal_Close), Name : "InpVal_Close", size: sizeof(TKalibrZero::InpVal_Close) }, //
		{ ctype : cpxNULL } };

const CpxDescr KalibrPtDscr[] = { //
		{ ctype : cpxFLOAT, id:cfgX_xValFiz, ofs: offsetof(TKalibrPt, valFiz), Name : "ValFiz", size: sizeof(TKalibrPt::valFiz) }, //
		{ ctype : cpxFLOAT, id:cfgX_xValMeas, ofs: offsetof(TKalibrPt, valMeas), Name : "ValMeas", size: sizeof(TKalibrPt::valMeas) }, //
		{ ctype : cpxNULL } };

const CpxChildInfo KalibrDtChild = {
		itemCnt : 1, itemSize : sizeof(TKalibrPt), defs : KalibrPtDscr };
const CpxDescr KalibrDtDscr[] = { //
		{ ctype : cpxCHILD, id:cfgX_yP0, ofs: offsetof(TKalibrDt, P0), Name : "P0", size:0, exPtr: &KalibrDtChild }, //
		{ ctype : cpxCHILD, id:cfgX_yP1, ofs: offsetof(TKalibrDt, P1), Name : "P1", size:0, exPtr: &KalibrDtChild }, //
		{ ctype : cpxNULL } };

const CpxChildInfo KalibrZeroChild = {
		itemCnt : 1, itemSize : sizeof(TKalibrZero), defs : KalibrZeroDscr };
const CpxChildInfo KalibrPtChild = {
		itemCnt : 1, itemSize : sizeof(TKalibrPt), defs : KalibrPtDscr };
const CpxDescr KalibrDtDblZeroDscr[] = { //
		{ ctype : cpxCHILD, id:cfgX_zZ0, ofs: offsetof(TKalibrDtDblZero, Z0), Name : "Z0", size:0, exPtr: &KalibrZeroChild }, //
		{ ctype : cpxCHILD, id:cfgX_zP1, ofs: offsetof(TKalibrDtDblZero, P1), Name : "P1", size:0, exPtr: &KalibrPtChild }, //
		{ ctype : cpxNULL } };

const CpxDescr TcpInterfDscr[] = { //
		{ ctype : cpxBYTE, id:cfgB_tDhcp, ofs: offsetof(TcpInterfDef, dhcp), Name : "dhcp", size: sizeof(TcpInterfDef::dhcp) }, //
		{ ctype : cpxIP, id:cfgB_tIp, ofs: offsetof(TcpInterfDef, ip), Name : "ip", size: sizeof(TcpInterfDef::ip) }, //
		{ ctype : cpxIP, id:cfgB_tMask, ofs: offsetof(TcpInterfDef, mask), Name : "mask", size: sizeof(TcpInterfDef::mask) }, //
		{ ctype : cpxIP, id:cfgB_tGw, ofs: offsetof(TcpInterfDef, gw), Name : "gw", size: sizeof(TcpInterfDef::gw) }, //
		{ ctype : cpxIP, id:cfgB_tDns1, ofs: offsetof(TcpInterfDef, dns1), Name : "dns1", size: sizeof(TcpInterfDef::dns1) }, //
		{ ctype : cpxIP, id:cfgB_tDns2, ofs: offsetof(TcpInterfDef, dns2), Name : "dns2", size: sizeof(TcpInterfDef::dns2) }, //

		{ ctype : cpxNULL } };

const CpxChildInfo KalibrDtDblZeroChild = {
		itemCnt : 1, itemSize : sizeof(TKalibrDtDblZero), defs : KalibrDtDblZeroDscr };
const CpxDescr BreakDscr[] = { //
		{ ctype : cpxBOOL, id:cfgB_bEnab, ofs: offsetof(TRollDevCfg_Sz, RollDevCfg.Enabled), Name : "Enab", size: sizeof(TRollDevCfg::Enabled) }, //
		{ ctype : cpxBYTE, id:cfgB_bPressBitNr, ofs: offsetof(TRollDevCfg_Sz, RollDevCfg.PressBitNr), Name : "PressBitNr", size: sizeof(TRollDevCfg::PressBitNr) }, //
		{ ctype : cpxBYTE, id:cfgB_bRollBitNr, ofs: offsetof(TRollDevCfg_Sz, RollDevCfg.RollBitNr), Name : "RollBitNr", size: sizeof(TRollDevCfg::RollBitNr) }, //
		{ ctype : cpxFLOAT, id:cfgB_bRollDiameter, ofs: offsetof(TRollDevCfg_Sz, RollDevCfg.RollDiameter), Name : "RollDiameter", size: sizeof(TRollDevCfg::RollDiameter) }, //
		{ ctype : cpxBYTE, id:cfgB_bAnInutNr, ofs: offsetof(TRollDevCfg_Sz, RollDevCfg.AnInutNr), Name : "AnInutNr", size: sizeof(TRollDevCfg::AnInutNr) }, //
		{ ctype : cpxINT, id:cfgB_bRollImpCnt, ofs: offsetof(TRollDevCfg_Sz, RollDevCfg.RollImpCnt), Name : "RollImpCnt", size: sizeof(TRollDevCfg::RollImpCnt) }, //
		{ ctype : cpxCHILD, id:cfgB_bKalibr, ofs: offsetof(TRollDevCfg_Sz, RollDevCfg.Kalibr), Name : "Kalibr", size:0, exPtr: &KalibrDtDblZeroChild }, //
		{ ctype : cpxBYTE, id:cfgB_bKalibQuqlity, ofs: offsetof(TRollDevCfg_Sz, RollDevCfg.KalibQuqlity), Name : "KalibQuqlity", size: sizeof(TRollDevCfg::KalibQuqlity) }, //
		{ ctype : cpxNULL } };

const CpxChildInfo SuspensKalibrLnChild = {
		itemCnt : 1, itemSize : sizeof(TKalibrDt), defs : KalibrDtDscr };
const CpxChildInfo SuspensKalibrTabChild = {
		itemCnt : 6, itemSize : sizeof(TKalibrPt), defs : KalibrPtDscr };

const CpxDescr SuspensionTabDscr[] = { //
		{ ctype : cpxBOOL, id:cfgB_sEnab, ofs: offsetof(TSuspensionDevCfg_Sz, SuspensionDevCfg.Enabled), Name : "Enab", size: sizeof(TSuspensionDevCfg::Enabled) }, //
		{ ctype : cpxBYTE, id:cfgB_sAnInutNr, ofs: offsetof(TSuspensionDevCfg_Sz, SuspensionDevCfg.AnInutNr), Name : "AnInutNr", size: sizeof(TSuspensionDevCfg::AnInutNr) }, //
		{ ctype : cpxWORD, id:cfgB_sDeactivTime, ofs: offsetof(TSuspensionDevCfg_Sz, SuspensionDevCfg.DeactivTime), Name : "DeactivTime", size : sizeof(TSuspensionDevCfg::DeactivTime) }, //
		{ ctype : cpxFLOAT, id:cfgB_sDeadZone, ofs: offsetof(TSuspensionDevCfg_Sz, SuspensionDevCfg.DeadZone), Name : "DeadZone", size: sizeof(TSuspensionDevCfg::DeadZone) }, //
		{ ctype : cpxCHILD, id:cfgB_sKalibrLin, ofs: offsetof(TSuspensionDevCfg_Sz, SuspensionDevCfg.KalibrLn), Name : "KalibrLin", size:0, exPtr: &SuspensKalibrLnChild }, //
		{ ctype : cpxCHILD, id:cfgB_sKalibr, ofs: offsetof(TSuspensionDevCfg_Sz, SuspensionDevCfg.KalibrTab), Name : "Kalibr", size:0, exPtr: &SuspensKalibrTabChild }, //
		{ ctype : cpxBYTE, id:cfgB_sKalibQuqlity, ofs: offsetof(TSuspensionDevCfg_Sz, SuspensionDevCfg.KalibQuqlity), Name : "KalibQuqlity", size : sizeof(TSuspensionDevCfg::KalibQuqlity) }, //
		{ ctype : cpxNULL } };

const CpxChildInfo SlipSideKalibrChild = {
		itemCnt : 1, itemSize : sizeof(TKalibrDt), defs : KalibrDtDscr };

const CpxDescr SlipSideDscr[] = { //
		{ ctype : cpxBOOL, id:cfgB_pEnab, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.Enabled), Name : "Enab", size: sizeof(TSlipSideDevCfg::Enabled) }, //
		{ ctype : cpxBYTE, id:cfgB_pTypPlyty, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.TypPlyty), Name : "TypPlyty", size: sizeof(TSlipSideDevCfg::TypPlyty) }, //
		{ ctype : cpxBYTE, id:cfgB_pPressNajazdNr, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.PressNajazdNr), Name : "PressNajazdNr", size: sizeof(TSlipSideDevCfg::PressNajazdNr) }, //
		{ ctype : cpxBYTE, id:cfgB_pPressZjazdNr, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.PressZjazdNr), Name : "PressZjazdNr", size : sizeof(TSlipSideDevCfg::PressZjazdNr) }, //
		{ ctype : cpxBYTE, id:cfgB_pAnInutNr, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.AnInutNr), Name : "AnInutNr", size: sizeof(TSlipSideDevCfg::AnInutNr) }, //
		{ ctype : cpxBOOL, id:cfgB_pInvertNajazd, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.InvertNajazd), Name : "InvertNajazd", size : sizeof(TSlipSideDevCfg::InvertNajazd) }, //
		{ ctype : cpxBOOL, id:cfgB_pInvertZjazd, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.InvertZjazd), Name : "InvertZjazd", size : sizeof(TSlipSideDevCfg::InvertZjazd) }, //
		{ ctype : cpxCHILD, id:cfgB_pKalibr, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.Kalibr), Name : "Kalibr", size:0, exPtr: &SlipSideKalibrChild }, //
		{ ctype : cpxFLOAT, id:cfgB_pMaxMeasTime, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.MaxMeasTime), Name : "MaxMeasTime", size : sizeof(TSlipSideDevCfg::MaxMeasTime) }, //
		{ ctype : cpxFLOAT, id:cfgB_pMinMeasTime, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.MinMeasTime), Name : "MinMeasTime", size : sizeof(TSlipSideDevCfg::MinMeasTime) }, //
		{ ctype : cpxFLOAT, id:cfgB_pDeActivTime, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.DeActivtime), Name : "DeActivTime", size: sizeof(TSlipSideDevCfg::DeActivtime) }, //
		{ ctype : cpxFLOAT, id:cfgB_pMaxMeasFlip, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.MaxMeasFlip), Name : "MaxMeasFlip", size : sizeof(TSlipSideDevCfg::MaxMeasFlip) }, //
		{ ctype : cpxFLOAT, id:cfgB_pMaxZeroShift, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.MaxStartZeroShift), Name : "MaxStartZeroShift", size: sizeof(TSlipSideDevCfg::MaxStartZeroShift) }, //
		{ ctype : cpxFLOAT, id:cfgB_pDeadZone, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.DeadZone), Name : "DeadZone", size: sizeof(TSlipSideDevCfg::DeadZone) }, //
		{ ctype : cpxFLOAT, id:cfgB_pMaxFlipTime, ofs: offsetof(TSlipSideDevCfg_Sz, SlipSideDevCfg.MaxFlipTime), Name : "MaxFlipTime", size: sizeof(TSlipSideDevCfg::MaxFlipTime) }, //

		{ ctype : cpxNULL } };

// --------- WAGA -------------------------------------

const CpxDescr WeightChnKalibrDscr[] = { //
		{ ctype : cpxBYTE, id:cfgC_wAnInputNr, ofs: offsetof(TWeightChnKalibr, AnInputNr), Name : "AnInputNr", size: sizeof(TWeightChnKalibr::AnInputNr) }, //
		{ ctype : cpxWORD, id:cfgC_wAnZero, ofs: offsetof(TWeightChnKalibr, AnZero), Name : "AnZero", size: sizeof(TWeightChnKalibr::AnZero) }, //
		{ ctype : cpxFLOAT, id:cfgC_wWspSkali, ofs: offsetof(TWeightChnKalibr, WspSkali), Name : "WspSkali", size: sizeof(TWeightChnKalibr::WspSkali) }, //
		{ ctype : cpxNULL } };

const CpxChildInfo WeightChnKalibrChild = {
		itemCnt : 4, itemSize : sizeof(TWeightChnKalibr), defs : WeightChnKalibrDscr };
const CpxChildInfo WeightKalibrChild = {
		itemCnt : 1, itemSize : sizeof(TKalibrDt), defs : KalibrPtDscr };
const CpxDescr WeightDscr[] = { //
		{ ctype : cpxBOOL, id:cfgB_wEnab, ofs: offsetof(TWeightDevCfg_Sz, WeightDevCfg.Enabled), Name : "Enab", size: sizeof(TWeightDevCfg::Enabled) }, //
		{ ctype : cpxCHILD, id:cfgB_wKalibr, ofs: offsetof(TWeightDevCfg_Sz, WeightDevCfg.P1), Name : "Kalibr", size:0, exPtr: &WeightKalibrChild }, //
		{ ctype : cpxCHILD, id:cfgB_wChnKalibr, ofs: offsetof(TWeightDevCfg_Sz, WeightDevCfg.chKalibr), Name : "ChnKalibr", size:0, exPtr: &WeightChnKalibrChild }, //
		{ ctype : cpxNULL } };

// --------- BINARY INPUT -------------------------------------

const CpxDescr BinInpChnDscr[] = { //
		{ ctype : cpxBOOL, id:cfgC_bEnab, ofs: offsetof(TBinAsAcOne, Enab), Name : "Enab", size: sizeof(TBinAsAcOne::Enab) }, //
		{ ctype : cpxWORD, id:cfgC_bLimitL, ofs: offsetof(TBinAsAcOne, RLow), Name : "LimitL", size: sizeof(TBinAsAcOne::RLow) }, //
		{ ctype : cpxWORD, id:cfgC_bLimitH, ofs: offsetof(TBinAsAcOne, RHigh), Name : "LimitH", size: sizeof(TBinAsAcOne::RHigh) }, //
		{ ctype : cpxNULL } };

const CpxChildInfo BinInpChnChild = {
		itemCnt : 8, itemSize : sizeof(TBinAsAcOne), defs : BinInpChnDscr };
const CpxDescr BinInpDscr[] = { //
		{ ctype : cpxCHILD, id:cfgB_bChn, ofs: offsetof(TTBinAsAc_Sz, BinAsAcCfg.inp), Name : "Inp", size:0, exPtr: &BinInpChnChild }, //
		{ ctype : cpxNULL } };

// --------- cala konfigurcja -------------------------------------

const CpxChildInfo TcpChild = {
		itemCnt : 1, itemSize : sizeof(TcpInterfDef), defs : TcpInterfDscr, flags:flagSHOWBR };
const CpxChildInfo BreakChild = {
		itemCnt : 1, itemSize : sizeof(TRollDevCfg_Sz), defs : BreakDscr, flags:flagSHOWBR };
const CpxChildInfo SuspensionChild = {
		itemCnt : 1, itemSize : sizeof(TSuspensionDevCfg_Sz), defs : SuspensionTabDscr, flags:flagSHOWBR };
const CpxChildInfo SlipSideChild = {
		itemCnt : 1, itemSize : sizeof(TSlipSideDevCfg_Sz), defs : SlipSideDscr, flags:flagSHOWBR };
const CpxChildInfo WeightChild = {
		itemCnt : 1, itemSize : sizeof(TWeightDevCfg_Sz), defs : WeightDscr, flags:flagSHOWBR };
const CpxChildInfo BinInpChild = {
		itemCnt : 1, itemSize : sizeof(TTBinAsAc_Sz), defs : BinInpDscr, flags:flagSHOWBR };

const CpxDescr ConfigDscr[] = { //
		{ ctype : cpxSTR, id:cfgA_SN, ofs: offsetof(CfgRec, P.SerialNr), Name : "SerialNr", sizeof(CfgRec::P.SerialNr) }, //
		{ ctype : cpxSTR, id:cfgA_DEVID, ofs: offsetof(CfgRec, P.DevID), Name : "DevID", sizeof(CfgRec::P.DevID) }, //
		{ ctype : cpxIP, id:cfgA_HostIP, ofs: offsetof(CfgRec, R.E.otherCfg.host_addr), Name : "HostIP", size: sizeof(OtherCfg::host_addr) }, //

		{ ctype : cpxCHILD, id:cfgA_TCP, ofs: offsetof(CfgRec, R.E.tcp), Name : "Tcp", size:0, exPtr: &TcpChild }, //
		{ ctype : cpxCHILD, id:cfgA_BREAK_L, ofs: offsetof(CfgRec, R.H[0]), Name : "Break_L", size:0, exPtr: &BreakChild }, //
		{ ctype : cpxCHILD, id:cfgA_BREAK_R, ofs: offsetof(CfgRec, R.H[1]), Name : "Break_R", size:0, exPtr: &BreakChild }, //
		{ ctype : cpxCHILD, id:cfgA_SUSP_L, ofs: offsetof(CfgRec, R.S[0]), Name : "Suspen_L", size:0, exPtr: &SuspensionChild }, //
		{ ctype : cpxCHILD, id:cfgA_SUSP_R, ofs: offsetof(CfgRec, R.S[1]), Name : "Suspen_R", size:0, exPtr: &SuspensionChild }, //
		{ ctype : cpxCHILD, id:cfgA_SLIPSIDE, ofs: offsetof(CfgRec, R.L), Name : "SlipSide", size:0, exPtr: &SlipSideChild }, //
		{ ctype : cpxCHILD, id:cfgA_WEIGHT_L, ofs: offsetof(CfgRec, R.W[0]), Name : "Weight_L", size:0, exPtr: &WeightChild }, //
		{ ctype : cpxCHILD, id:cfgA_WEIGHT_R, ofs: offsetof(CfgRec, R.W[1]), Name : "Weight_R", size:0, exPtr: &WeightChild }, //
		{ ctype : cpxCHILD, id:cfgA_BIN_AC, ofs: offsetof(CfgRec, R.B), Name : "BinInp", size:0, exPtr: &BinInpChild }, //

		{ ctype : cpxNULL }

		};

#define  CFG_SIGN  0x2367A3B7

Config::Config() {
	memset(&data, 0, sizeof(data));
}

uint32_t Config::getDevInfoSpecDevData() {
	uint32_t w = 0;

	if (data.R.H[0].RollDevCfg.Enabled)
		w |= 0x0001;
	if (data.R.H[1].RollDevCfg.Enabled)
		w |= 0x0002;
	if (data.R.S[0].SuspensionDevCfg.Enabled)
		w |= 0x0004;
	if (data.R.S[1].SuspensionDevCfg.Enabled)
		w |= 0x0008;
	if (data.R.L.SlipSideDevCfg.Enabled)
		w |= 0x0010;
	if (data.R.W[0].WeightDevCfg.Enabled)
		w |= 0x0020;
	if (data.R.W[1].WeightDevCfg.Enabled)
		w |= 0x0040;
	return w;
}

void Config::getDataInfo(CfgDataInfo *info) {
	info->adr = &data;
	info->size = sizeof(data);
	info->dscr = ConfigDscr;
	info->histCfg = &data.H;
	info->baseCfg = &data.P;
}

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
	data.R.E.tcp.dhcp = false;
	ipaddr_aton("192.168.254.162", &data.R.E.tcp.ip);
	ipaddr_aton("255.255.255.0", &data.R.E.tcp.mask);
	ipaddr_aton("192.168.254.254", &data.R.E.tcp.gw);
	ipaddr_aton("192.168.254.254", &data.R.E.tcp.dns1);
	ipaddr_aton("8.8.8.8", &data.R.E.tcp.dns2);
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
	def->dhcp = data.R.E.tcp.dhcp;
	def->ip = data.R.E.tcp.ip;
	def->mask = data.R.E.tcp.mask;
	def->gw = data.R.E.tcp.gw;
}

void Config::setTcpDef(const TcpCfgInterfDef *def) {
	data.R.E.tcp.dhcp = def->dhcp;
	data.R.E.tcp.ip = def->ip;
	data.R.E.tcp.mask = def->mask;
	data.R.E.tcp.gw = def->gw;
	save();
	delayReconfigNet(1000);

}
