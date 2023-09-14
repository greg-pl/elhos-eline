/*
 * shell.cpp
 *
 *  Created on: Dec 5, 2020
 *      Author: Grzegorz
 */

#include "stdlib.h"
#include "stdio.h"
#include "string.h"
#include "stdarg.h"

#include <lwip.h>
#include <dns.h>
#include <icmp.h>
#include <sockets.h>
#include <inet_chksum.h>

#include "TaskClass.h"
#include <ShellInterpreter.h>
#include <EscTerminal.h>
#include <Hdw.h>
#include <utils.h>
#include <ethernetif.h>
#include <I2cDev.h>
#include <UMain.h>
#include <Config.h>
#include <Token.h>
#include <engine.h>

extern Config *config;


extern void showDefaultTaskStatus(OutStream *strm);

ShellInterpreter::ShellInterpreter() :
		BaseDevShellInterpreter::BaseDevShellInterpreter() {

}

const char* ShellInterpreter::getMainMenuCap() {
	return "   eLINE-KP";
}

void ShellInterpreter::meShowHdwState(OutStream *strm) {

}



void ShellInterpreter::meShowDevState(OutStream *strm) {
	strm->oMsg("AN.StartCnt     :%u", AnInput::getStartCnt());
	strm->oMsg("AN.DoneCnt      :%u", AnInput::getDoneCnt());
	strm->oMsg("DIN.DoneCnt     :%u", DigInput::getSampleNr());
	showDefaultTaskStatus(strm);
}

//--------hdMenu-----------------------------------------------------------------
const ShellItem menuHd[] = { //
		{ "s", "pokaż stan" }, //
		{ "pl", "ustaw linie PL" }, //
		{ NULL, NULL } };

void ShellInterpreter::hdMenu(OutStream *strm, const char *cmd) {
	char tok[20];
	int idx = -1;
	if (Token::get(&cmd, tok, sizeof(tok)))
		idx = findCmd(menuHd, tok);
	switch (idx) {
	case 0:
		if (strm->oOpen(colWHITE)) {
			char txt[10];
			strm->oMsg("KEY1=%u", Hdw::getKey1());
			uint8_t jp = Hdw::getJMP();
			uint8_t pls = Hdw::getPLs();
			uint8_t dIn = Hdw::getDINs();
			uint8_t dInMode = Hdw::getDinMode();

			strm->oMsg("JMP     :0x%02X : %s", jp, binStr(txt, jp, 4));
			strm->oMsg("PL      :0x%02X : %s", pls, binStr(txt, pls, 8));
			strm->oMsg("DIN     :0x%02X : %s", dIn, binStr(txt, dIn, 8));
			strm->oMsg("DIN_MODE:0x%02X : %s", dInMode, binStr(txt, dInMode, 8));
			strm->oClose();
		}
		break;
	case 1: {
		int pknr;
		bool val;

		if (Token::getAsInt(&cmd, &pknr)) {
			if (Token::getAsBool(&cmd, &val)) {
				if (pknr >= 0 && pknr < Hdw::AN_CNT) {
					Hdw::setPL(pknr, val);
					strm->oMsgX(colWHITE, "set PK[%u]=%u", pknr, val);
				} else
					strm->oMsgX(colRED, "Pknr=[1..%u]", Hdw::AN_CNT);
			}
		}
	}
		break;

	default:
		showHelp(strm, "Hardware Menu", menuHd);
		break;
	};
}

const ShellItem mainKpMenu[] = { //
		{ "hd", ">> hardware menu" }, //
		{ "cfg", ">> config menu" }, //
		{ "din", "[F4] show DIN state" }, //
		{ "an", "[F5] Show AN state" }, //
		{ "an_test", "test analog:getSampleByNr" }, //

		{ NULL, NULL } };

const ShellItem* ShellInterpreter::getChildMenu() {
	return mainKpMenu;
}

void ShellInterpreter::testAnalog(OutStream *strm) {
#define TEST_CNT 100
	uint16_t tabVal[TEST_CNT];
	bool tabR[TEST_CNT];

	int samplNr = AnInput::getSampleNr();
	for (int i = 0; i < TEST_CNT; i++) {
		tabR[i] = AnInput::getSampleByNr(7, samplNr - i, &tabVal[i]);
	}
	int cntE1 = 0;
	for (int i = 0; i < TEST_CNT; i++) {
		if (!tabR[i])
			cntE1++;
	}

	int cntE2 = 0;
	for (int i = 1; i < TEST_CNT; i++) {
		if (tabVal[i] != tabVal[i - 1] - 1)
			cntE2++;
	}

	strm->oMsgX(colWHITE, "TestAnalog: samplNr=%u cntE1=%u cntE2=%u", samplNr, cntE1, cntE2);

}

bool ShellInterpreter::execChildFun(OutStream *strm, int idx, const char *cmd) {
	switch (idx) {
	case 0: //hd
		hdMenu(strm, cmd);
		break;
	case 1: //cfg
		config->shell(strm, cmd);
		break;
	case 2: //din
		DigInput::showState(strm);
		break;
	case 3: //an
		AnInput::showState(strm);
		break;
	case 4: //an_test
		testAnalog(strm);
		break;
	default:
		return false;
	}
	return true;
}

extern "C" void SpiCsTest();

void ShellInterpreter::execFunKey(OutStream *strm, FunKey funKey) {
	BaseDevShellInterpreter::execFunKey(strm, funKey);
	switch (funKey) {
	default:
	case fnF4:
		DigInput::showState(strm);
		break;
	case fnF5:
		AnInput::showState(strm);
		break;
	}
}
