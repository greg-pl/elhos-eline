/*
 * BaseDevShellInterpreter.cpp
 *
 *  Created on: Mar 23, 2021
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

#include <Token.h>
#include "TaskClass.h"
#include <BaseDevShellInterpreter.h>
#include <EscTerminal.h>
#include <Hdw.h>
#include <utils.h>
#include <ethernetif.h>
#include <I2cDev.h>
#include <UMain.h>
#include "TcpSvrTask.h"


extern TcpSvrTask *svrTask;

BaseDevShellInterpreter::BaseDevShellInterpreter() {
	pingObj = NULL;
}
//-------------------------------------------------------------------------------------------------------------------------
// ShellEngine
//-------------------------------------------------------------------------------------------------------------------------



void BaseDevShellInterpreter::meShowHdwState(OutStream *strm){

}

void BaseDevShellInterpreter::showHdwState(OutStream *strm) {
	static int showCnt;
	if (strm->oOpen(colYELLOW)) {
		strm->oMsg("--- %u ----------", showCnt++);
		meShowHdwState(strm);
		strm->oClose();
	}

}

void BaseDevShellInterpreter::meShowDevState(OutStream *strm){

}
void BaseDevShellInterpreter::showDevState(OutStream *strm) {
	static int showCnt;
	if (strm->oOpen(colWHITE)) {
		strm->oMsg("--- %u ----------", showCnt++);
		char buf[20];
		TimeTools::DtTmStr(buf, &mSoftVer.time);
		strm->oMsg("Ver             :%u.%03u - %s", mSoftVer.ver, mSoftVer.rev, buf);
		meShowDevState(strm);
		strm->oClose();
	}
}

void BaseDevShellInterpreter::execFunKey(OutStream *strm, FunKey funKey) {
	//msg(colYELLOW, "FunKey=%u", funKey);
	switch (funKey) {
	case fnF1:
		showMainMenu(strm);
		break;
	case fnF2:
		showDevState(strm);
		break;
	case fnF3:
		showHdwState(strm);
		break;
	default:
		break;

	}
}

void BaseDevShellInterpreter::execAltChar(OutStream *strm, char altChar) {
	char buf[40];
	snprintf(buf, sizeof(buf), "AltChar=%u [%c]", altChar, altChar);
	strm->oMsgX(colRED, buf);
}

//--------EthMenu-----------------------------------------------------------------
const ShellItem menuEth[] = { //
		{ "s", "status etherneta" }, //
				{ "reset", "impuls reset do PHY" }, //
				{ "reg", "pokaż rejestry PHY" }, //
				{ NULL, NULL } };

typedef struct {
	const char *name;
	int adr;
} PhyRegItemDef;
const PhyRegItemDef phyRegTab[] = { //
		{ "BCR", 0 }, //
				{ "BSR", 1 }, //
				{ "ID1", 2 }, //
				{ "ID2", 3 }, //
				{ "NegAdver", 4 }, //
				{ "NegPartner", 5 }, //
				{ "NegExpan", 6 }, //
				{ "Mode Control/Status Reg", 17 }, //
				{ "Special Mode Reg", 18 }, //
				{ "SymbolErrCntReg", 26 }, //
				{ "Special Control/Status Indications Register", 27 }, //
				{ "Interrupt Source Flag Register", 29 }, //
				{ "Interrupt Mask Register", 30 }, //
				{ "PHY Special Control/Status Register", 31 }, //
				{ NULL, -1 }, };

extern "C" void ethGetPhyReg(const uint16_t *adrTab, uint16_t *valTab);

void BaseDevShellInterpreter::ethMenu(OutStream *strm, const char *cmd) {
	char tok[20];
	int idx = -1;
	if (Token::get(&cmd, tok, sizeof(tok)))
		idx = findCmd(menuEth, tok);
	switch (idx) {
	case 0:
		break;
	case 1:
		strm->oMsgX(colWHITE, "PHY Reset");
		Hdw::phyReset(1);
		osDelay(50);
		Hdw::phyReset(0);
		break;

	case 2: {
		uint16_t adrTab[30];
		uint16_t valTab[30];
		int k = 0;
		while (phyRegTab[k].name != NULL) {
			adrTab[k] = phyRegTab[k].adr;
			k++;
		}
		adrTab[k] = 0xFFFF;
		ethGetPhyReg(adrTab, valTab);
		if (strm->oOpen(colWHITE)) {
			int k = 0;
			while (phyRegTab[k].name != NULL) {
				strm->oMsg("%2u. %04X %s", phyRegTab[k].adr, valTab[k], phyRegTab[k].name);
				k++;
			}
			strm->oClose();
		}

	}
		break;

	default:
		showHelp(strm, "Ethernet Menu", menuEth);
		break;
	};
}

//--------NetMenu-----------------------------------------------------------------
const ShellItem menuNet[] = { //
		{ "s", "pokaż stan" }, //
				{ "restart", "rekonfiguruj net" }, //
				{ "getip", "użyj DNS" }, //
				{ "ping", "ping" }, //
				{ NULL, NULL } };

ip_addr_t globAddr;

void dns_found_cb(const char *name, const ip_addr_t *ipaddr, void *callback_arg) {
	if (ipaddr != NULL && ipaddr->addr != 0) {
		char txt[20];
		ipaddr_ntoa_r(ipaddr, txt, sizeof(txt));
		getOutStream()->oMsgX(colGREEN, "%s -> %s", name, txt);
	} else {
		getOutStream()->oMsgX(colRED, "%s -> ???", name);
	}
}

void BaseDevShellInterpreter::netMenu(OutStream *strm, const char *cmd) {
	char tok[20];
	int idx = -1;

	if (Token::get(&cmd, tok, sizeof(tok)))
		idx = findCmd(menuNet, tok);
	switch (idx) {
	case 0: //s
	{
		NetState netState;
		char txt[20];

		getNetIfState(&netState);
		if (strm->oOpen(colWHITE)) {
			strm->oMsg("LinkUp:%s", YN(netState.LinkUp));
			strm->oMsg("Dhcp:%s", OnOff(netState.DhcpOn));
			strm->oMsg("DhcpRdy:%s", YN(netState.DhcpRdy));
			if (netState.ipValid) {
				ipaddr_ntoa_r(&netState.CurrIP, txt, sizeof(txt));
				strm->oMsg("IP:%s", txt);
				ipaddr_ntoa_r(&netState.CurrMask, txt, sizeof(txt));
				strm->oMsg("Mask:%s", txt);
				ipaddr_ntoa_r(&netState.CurrGate, txt, sizeof(txt));
				strm->oMsg("GateWay:%s", txt);
			}
			const ip_addr_t *pdns1 = dns_getserver(0);
			ipaddr_ntoa_r(pdns1, txt, sizeof(txt));
			strm->oMsg("DNS_1:%s", txt);
			const ip_addr_t *pdns2 = dns_getserver(1);
			ipaddr_ntoa_r(pdns2, txt, sizeof(txt));
			strm->oMsg("DNS_2:%s", txt);

			strm->oClose();
		}

	}

		break;
	case 1: //restart
		strm->oMsgX(colWHITE, "Network reconfig");
		reconfigNet();

		break;
	case 2: //getip
	{
		Token::trim(&cmd);
		int err = dns_gethostbyname(cmd, &globAddr, &dns_found_cb, NULL);
		switch (err) {
		case ERR_OK: //
		{
			char txt[20];
			ipaddr_ntoa_r(&globAddr, txt, sizeof(txt));
			strm->oMsgX(colGREEN, "IME %s -> %s", cmd, txt);
		}
			break;
		case ERR_INPROGRESS:
			break;
		default:
			strm->oMsgX(colRED, "Error :%d", err);
		}

	}
		break;
	case 3: //ping
	{
		if (pingObj == NULL)
			pingObj = new PingObj();
		if (pingObj != NULL) {

			Token::trim(&cmd);

			ip4_addr_t addr;
			if (ipaddr_aton(cmd, &addr)) {
				if (strm->oOpen(colWHITE)) {
					pingObj->ping(strm, &addr, 4);
					strm->oClose();
				}
			}
		}
	}
		break;
	default:
		showHelp(strm, "Net Menu", menuNet);
		break;
	};
}


void *mem_try = NULL;

extern uint8_t _end; /* Symbol defined in the linker script */
extern uint8_t _estack; /* Symbol defined in the linker script */
extern uint32_t _Min_Stack_Size; /* Symbol defined in the linker script */

void BaseDevShellInterpreter::showMemInfo(OutStream *strm) {
	if (strm->oOpen(colWHITE)) {
		if (mem_try == NULL)
			mem_try = malloc(4);

		const uint32_t stack_start = (uint32_t) &_end;
		const uint32_t stack_limit = (uint32_t) &_estack - (uint32_t) &_Min_Stack_Size;

		strm->oMsg("heap_begin= %p", stack_start);
		strm->oMsg("heap_end= %p", stack_limit);
		strm->oMsg("heap_curr = %p", mem_try);

		int size = stack_limit - stack_start;
		int used = (int) mem_try - stack_start;
		int freem = size - used;
		int stack_sz = (uint32_t) &_Min_Stack_Size;

		strm->oMsg("heap_size = %u (%p)", size, size);
		strm->oMsg("heap_used = %u (%p)", used, used);
		strm->oMsg("heap_free = %u (%p)", freem, freem);
		strm->oMsg("stack_size = %u (%p)", stack_sz, stack_sz);

		strm->oClose();
	}
}
void BaseDevShellInterpreter::showTaskList(OutStream *strm) {
	if (strm->oOpen(colWHITE)) {
		char *bigbuf;
		bigbuf = (char*) malloc(2000);
		if (bigbuf != NULL) {
			vTaskList(bigbuf);
			strm->oMsg("TXT_SIZE=%u (max %u) (p=%08X)", strlen(bigbuf), 2000, (int) bigbuf);
			strm->oMsg("Name\t\tState\tPrior.\tStackP\tNum");
			strm->oWr(bigbuf);
			free(bigbuf);
		} else
			strm->oMsg("NoFreeMem for Buffer");

		strm->oClose();
	}

}


const ShellItem mainBaseDevMenu[] = { //
		{ "s", "[F2] status urządzenia" }, //
				{ "h", "[F3] stan hardware" }, //
				{ "reboot", "reboot STM" }, //
				{ "eth", ">> menu etherneta" }, //
				{ "net", ">> menu tcp/ip" }, //
				{ "iic", ">> menu układów i2c" }, //
				{ "svr", ">> menu servera TCP" }, //


				{ "ps", "lista tasków" }, //
				{ "psx", "lista tasków ex" }, //
				{ "mem", "informacja o pamięci" }, //
				{ "lcd_scr", "ustawienie numer wyświetlanego ekranu" }, //
				{ "lcd_time", "ustawienie czasu przełaczania ekranów na lcd" }, //
				{ "exit", "zamknij sesje" }, //

				{ NULL, NULL } };

bool BaseDevShellInterpreter::execOwnCmdLine(OutStream *strm, int idx, const char *cmd) {
	switch (idx) {
	case 0:
		showDevState(strm);
		break;
	case 1:
		showHdwState(strm);
		break;
	case 2:
		strm->oMsgX(colRED, "*** R E S E T ***");
		reboot(1000);
		break;
	case 3:
		ethMenu(strm, cmd);
		break;
	case 4:
		netMenu(strm, cmd);
		break;
	case 5: //iic
		I2c1Bus::shell(strm, cmd);
		break;
	case 6: //svr
		svrTask->shell(strm, cmd);
		break;


//--------------------------
	case 7: //ps
		showTaskList(strm);
		break;
	case 8: //psx
		TaskClassList::ShowList(strm);
		break;
	case 9: //mem
		showMemInfo(strm);
		break;

	case 10: { //lcd_scr
		int v;
		Token::getAsInt(&cmd, &v);
		//setLcdScrNr(v);
	}
		break;
	case 11: { //lcd_time
		int v;
		Token::getAsInt(&cmd, &v);
		//setLcdTime(v);
	}
		break;
	case 12:  //exit
		strm->closeTerm();
		break;

	default:
		return  false;
	};
	return  true;

}

void BaseDevShellInterpreter::showMainMenu(OutStream *strm){
	const ShellItem *menuTab[3];

	menuTab[0] = mainBaseDevMenu;
	menuTab[1] = getChildMenu();
	menuTab[2] = NULL;

	showHelpEx(strm, getMainMenuCap(), menuTab);
}


void BaseDevShellInterpreter::execCmdLine(OutStream *strm, const char *cmd) {
	char tok[20];
	const ShellItem *menuTab[3];

	menuTab[0] = mainBaseDevMenu;
	menuTab[1] = getChildMenu();
	menuTab[2] = NULL;

	FindRes idxG;
	idxG.idx = -1;
	idxG.mnIdx = -1;

	if (Token::get(&cmd, tok, sizeof(tok)))
		findCmdEx(&idxG, menuTab, tok);
	bool fnd = false;
	switch(idxG.mnIdx){
	case 0:
		fnd = execOwnCmdLine(strm, idxG.idx,cmd);
		break;

	case 1:
		fnd = execChildFun(strm, idxG.idx, cmd);
		break;
	}
	if (!fnd)
		showMainMenu(strm);
}
