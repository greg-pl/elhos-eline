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
#include <Token.h>
#include <ethernetif.h>
#include <I2cDev.h>
#include <UMain.h>
#include <RFM69.h>
#include <ModbusMaster.h>
#include <LogKey.h>
#include <Pilot.h>
#include <Engine.h>

extern TModbusMaster *modbusMaster;
extern LogKey *logKey;
extern Engine *engine;

ShellInterpreter::ShellInterpreter() :
		BaseDevShellInterpreter::BaseDevShellInterpreter() {

}

const char* ShellInterpreter::getMainMenuCap() {
	return "eLINE-HOST";
}

void ShellInterpreter::meShowHdwState(OutStream *strm) {

}
void ShellInterpreter::meShowDevState(OutStream *strm) {

}

//--------hdMenu-----------------------------------------------------------------
const ShellItem menuHd[] = { //
		{ "s", "pokaż stan" }, //
		{ "pk", "ustaw przekaźnik" }, //
		{ "buz", "Buzzer beep" }, {
				NULL, NULL } };

void ShellInterpreter::hdMenu(OutStream *strm, const char *cmd) {
	char tok[20];
	int idx = -1;
	if (Token::get(&cmd, tok, sizeof(tok)))
		idx = findCmd(menuHd, tok);
	switch (idx) {
	case 0:
		if (strm->oOpen(colWHITE)) {
			strm->oMsg("KEY1=%u", Hdw::getKey1());
			strm->oMsg("INP1:%u  INP2:%u", Hdw::getInp1(), Hdw::getInp2());
			bool t[Hdw::PK_CNT];
			for (int i = 0; i < Hdw::PK_CNT; i++) {
				t[i] = Hdw::getPK(i + 1);
			}
			strm->oMsg("PK1:%u PK2:%u PK3:%u PK4:%u PK5:%u PK6:%u PK7:%u PK8:%u ", t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7]);

			strm->oClose();
		}
		break;
	case 1: {
		int pknr;
		bool val;

		if (Token::getAsInt(&cmd, &pknr)) {
			if (Token::getAsBool(&cmd, &val)) {
				if (pknr >= 1 && pknr <= Hdw::PK_CNT) {
					engine->setPk(pknr, val);
					strm->oMsgX(colWHITE, "set PK[%u]=%u", pknr, val);
				} else
					strm->oMsgX(colRED, "Pknr=[1..%u]", Hdw::PK_CNT);
			}
		}
	}
		break;
	case 2: { //buz
		Hdw::setBuzzer(1);
		osDelay(200);
		Hdw::setBuzzer(0);
	}
		break;

	default:
		showHelp(strm, "Hardware Menu", menuHd);
		break;
	};
}

const ShellItem mainKpMenu[] = { //
		{ "cfg", ">> config menu" }, //
		{ "rd", ">> menu radia" }, //
		{ "plt", ">> menu pilot" }, //
		{ "mdb", ">> menu modbus" }, //
		{ "hd", ">> hardware menu" }, //
		{ "key", ">> logKey menu" }, //

		{ NULL, NULL } };

const ShellItem* ShellInterpreter::getChildMenu() {
	return mainKpMenu;
}

bool ShellInterpreter::execChildFun(OutStream *strm, int idx, const char *cmd) {
	switch (idx) {
	case 0: //cfg
		config->shell(strm, cmd);
		break;
	case 1: //rd
		RFM69::shell(strm, cmd);
		break;
	case 2: //plt
		Pilot::shell(strm, cmd);
		break;
	case 3: //mdb
		modbusMaster->shell(strm, cmd);
		break;
	case 4: //hd
		hdMenu(strm, cmd);
		break;
	case 5: //key
		logKey->shell(strm, cmd);
		break;
	default:
		return false;
	}
	return true;
}

