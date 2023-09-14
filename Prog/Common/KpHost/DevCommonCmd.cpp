/*
 * DevCommonCmd.cpp
 *
 *  Created on: 16 kwi 2021
 *      Author: Grzegorz
 */

#include <string.h>
#include <stdlib.h>

#include <DevCommonCmd.h>
#include "UMain.h"
#include "hdw.h"
#include "Config.h"
#include <KObj.h>
#include <BaseDev.h>
#include <CfgBase.h>
#include <Utils.h>
#include <CxBuf.h>

enum {
#include  "DevCommon.ctg"
};

typedef struct __PACKED {
	uint8_t devType;
	uint8_t hdwVer;
	VerInfo firmVer;
	uint32_t devSpecData;
	char DevID[SIZE_DEV_NAME];
	char SerialNr[SIZE_SERIAL_NR];
} DevInfo;

uint8_t DevCommonCmd::AuthBuf[0x80];

__NO_RETURN __STATIC_INLINE SEC_RAM_FUNC void R_NVIC_SystemReset(void) {
	__DSB(); /* Ensure all outstanding memory accesses included
	 buffered write are completed before reset */
	SCB->AIRCR = (uint32_t) ((0x5FAUL << SCB_AIRCR_VECTKEY_Pos) | (SCB->AIRCR & SCB_AIRCR_PRIGROUP_Msk) |
	SCB_AIRCR_SYSRESETREQ_Msk); /* Keep priority group unchanged */
	__DSB(); /* Ensure completion of memory access */

	for (;;) /* wait until reset */
	{
		__NOP();
	}
}

SEC_RAM_FUNC static TStatus R_FLASH_WaitForLastOperation() {

	while (__HAL_FLASH_GET_FLAG(FLASH_FLAG_BSY) != RESET) {

	}

	/* Check FLASH End of Operation flag  */
	if (__HAL_FLASH_GET_FLAG(FLASH_FLAG_EOP) != RESET) {
		/* Clear FLASH End of Operation pending bit */
		__HAL_FLASH_CLEAR_FLAG(FLASH_FLAG_EOP);
	}
	uint32_t sr = FLASH->SR;
	uint32_t mask = FLASH_FLAG_OPERR | FLASH_FLAG_WRPERR | FLASH_FLAG_PGAERR |
	FLASH_FLAG_PGPERR | FLASH_FLAG_PGSERR | FLASH_FLAG_RDERR;

	if ((sr & mask) != 0) {
		FLASH->SR = mask;
		return stError;
	}
	return stOK;

}

SEC_RAM_FUNC static void R_FLASH_Erase_Sector(uint32_t Sector) {
	uint32_t tmp_psize = FLASH_PSIZE_WORD;

	if (Sector > FLASH_SECTOR_11) {
		Sector += 4U;
	}
	/* If the previous operation is completed, proceed to erase the sector */
	CLEAR_BIT(FLASH->CR, FLASH_CR_PSIZE);
	FLASH->CR |= tmp_psize;
	CLEAR_BIT(FLASH->CR, FLASH_CR_SNB);
	FLASH->CR |= FLASH_CR_SER | (Sector << FLASH_CR_SNB_Pos);
	FLASH->CR |= FLASH_CR_STRT;
}

SEC_RAM_FUNC void R_FLASH_FlushCaches(void) {
	/* Flush instruction cache  */
	if (READ_BIT(FLASH->ACR, FLASH_ACR_ICEN) != RESET) {
		/* Disable instruction cache  */
		__HAL_FLASH_INSTRUCTION_CACHE_DISABLE();
		/* Reset instruction cache */
		__HAL_FLASH_INSTRUCTION_CACHE_RESET();
		/* Enable instruction cache */
		__HAL_FLASH_INSTRUCTION_CACHE_ENABLE();
	}

	/* Flush data cache */
	if (READ_BIT(FLASH->ACR, FLASH_ACR_DCEN) != RESET) {
		/* Disable data cache  */
		__HAL_FLASH_DATA_CACHE_DISABLE();
		/* Reset data cache */
		__HAL_FLASH_DATA_CACHE_RESET();
		/* Enable data cache */
		__HAL_FLASH_DATA_CACHE_ENABLE();
	}
}

extern "C" SEC_RAM_FUNC TStatus R_HAL_FLASHEx_Erase(int sekNr, int sekCnt) {

	R_FLASH_WaitForLastOperation();

	TStatus st = stOK;
	for (int idx = sekNr; idx < (sekNr + sekCnt); idx++) {
		R_FLASH_Erase_Sector(idx);

		st = R_FLASH_WaitForLastOperation();

		/* If the erase operation is completed, disable the SER and SNB Bits */
		CLEAR_BIT(FLASH->CR, (FLASH_CR_SER | FLASH_CR_SNB));

		if (st != stOK) {
			break;
		}
	}

	R_FLASH_FlushCaches();

	return st;
}

SEC_RAM_FUNC void R_CopyFlash_1(uint32_t adr_dst, uint32_t adr_src, uint32_t size) {
	nir.itmp2 = 0x1001;
	__disable_irq();
	nir.itmp2 = 0x1002;

	R_HAL_FLASHEx_Erase(0, 8);
	nir.itmp2 = 0x1003;
	R_FLASH_WaitForLastOperation();
	nir.itmp2 = 0x1004;

	uint32_t *src = (uint32_t*) adr_src;

	int i = 0;
	int n = size / 4;
	while (i < n) {
		nir.itmp2 = 0x1004;

		//programowanie
		CLEAR_BIT(FLASH->CR, FLASH_CR_PSIZE);
		FLASH->CR |= FLASH_PSIZE_WORD;
		FLASH->CR |= FLASH_CR_PG;

		*(__IO uint32_t*) adr_dst = *src++;
		nir.itmp2 = 0x1005;

		//Odczekanie na zakończenie operacji
		TStatus st = R_FLASH_WaitForLastOperation();
		nir.itmp2 = 0x1006;
		FLASH->CR &= (~FLASH_CR_PG);
		nir.itmp2 = 0x1007;

		if (st != stOK) {
			break;
		}
		adr_dst += 4;
		i++;
	}
	nir.itmp2 = 0x1008;

	R_NVIC_SystemReset();
	nir.itmp2 = 0x1009;
}

extern "C" void CopyFlash(uint32_t adr_dst, uint32_t adr_src, uint32_t size) {

	TStatus st = (TStatus) HAL_FLASH_Unlock();
	if (st == stOK) {
		R_CopyFlash_1(adr_dst, adr_src, size);
	}
}

void DevCommonCmd::sendDevInfo(SvrTargetStream *trg) {
	DevInfo devInfo;

	getOutStream()->oMsgX(colYELLOW, "sendDevInfo");
	devInfo.devType = DEV_TYPE;
	devInfo.hdwVer = Hdw::getHdwVer();
	devInfo.firmVer = mSoftVer;
	strlcpy(devInfo.SerialNr, config->data.P.SerialNr, sizeof(devInfo.SerialNr));

	strlcpy(devInfo.DevID, config->data.P.DevID, sizeof(devInfo.DevID));
	devInfo.devSpecData = config->getDevInfoSpecDevData();

	trg->addToSend(dsdDEV_COMMON, msgDevInfo, &devInfo, sizeof(devInfo));
	trg->sendNow();
}

void DevCommonCmd::sendAuthorBuf(SvrTargetStream *trg) {

	for (int i = 0; i < (int) sizeof(AuthBuf); i++) {
		AuthBuf[i] = getRandom16() & 0xff;
	}
	trg->addToSend(dsdDEV_COMMON, msgGetAuthoBuf, &AuthBuf, sizeof(AuthBuf));
	trg->sendNow();
}

void DevCommonCmd::SendKeepAlive(SvrTargetStream *trg) {
	trg->addToSend(dsdDEV_COMMON, msgKeepAlive, NULL, 0);
	trg->sendNow();
}

void DevCommonCmd::clearUserflash(SvrTargetStream *trg) {
	FLASH_EraseInitTypeDef EraseRec;
	uint32_t SectorError;

	uint32_t tt = HAL_GetTick();

	TStatus st = (TStatus) HAL_FLASH_Unlock();
	if (st == stOK) {

		FLASH_WaitForLastOperation(1000);

		EraseRec.TypeErase = FLASH_TYPEERASE_SECTORS;
		EraseRec.VoltageRange = FLASH_VOLTAGE_RANGE_3;
		EraseRec.Sector = UFLASH_START_SEC;
		EraseRec.NbSectors = UFLASH_SEC_CNT;
		EraseRec.Banks = FLASH_BANK_1;

		st = (TStatus) HAL_FLASHEx_Erase(&EraseRec, &SectorError);
	}
	KUFlashRply rply;
	memset(&rply, 0, sizeof(rply));
	rply.status = st;
	rply.adr = SectorError;
	trg->addToSend(dsdDEV_COMMON, msgClrUserFlash, &rply, sizeof(rply));
	trg->sendNow();

	tt = HAL_GetTick() - tt;
	getOutStream()->oMsgX(colGREEN, "clearUF st=%d  Ardr=0x%06X tt=%u[ms]", rply.status, rply.adr, tt);

}

void DevCommonCmd::wrtieUserflash(SvrTargetStream *trg, uint8_t *data, int len) {

	TStatus st = stOK;

	if (((int) data & 0x03) != 0) {
		st = stNotAllignedData;
	}
	if (st == stOK) {
		KFlashDt *head;
		head = (KFlashDt*) data;
		uint32_t tt = HAL_GetTick();
		if (head->Adr + head->dtLen < UFLASH_SIZE) {
			if (head->dtLen > 0 && (head->dtLen & 0x0003) == 0) {
				st = (TStatus) HAL_FLASH_Unlock();
				if (st == stOK) {

					uint32_t Adr = UFLASH_BASE_ADR + head->Adr;
					int i = 0;
					int n = head->dtLen / 4;
					while (i < n) {
						uint32_t d2 = head->buf[i];
						st = (TStatus) HAL_FLASH_Program(FLASH_TYPEPROGRAM_WORD, Adr, d2);
						if (st != stOK) {
							break;
						}
						Adr += 4;
						i++;
					}
					HAL_FLASH_Lock();
				}
				if (st == stOK) {
					if (memcmp(head->buf, (void*) (UFLASH_BASE_ADR + head->Adr), head->dtLen) != 0)
						st = stCompareError;

				}

			} else
				st = stAdrTooBig;
			tt = HAL_GetTick() - tt;
			//getOutStream()->oMsgX(colGREEN, "writeUF Ardr=0x%06X L=%u st=%d tt=%u[ms]", head->Adr, head->dtLen, st, tt);

		} else
			st = stLengthNoAllign;
	}
	trg->addToSend(dsdDEV_COMMON, msgWriteUserFlash, &st, sizeof(st));
	trg->sendNow();
}

void DevCommonCmd::readFlashUni(SvrTargetStream *trg, uint8_t *data, int len, uint32_t baseAdr) {
	KFlashDt *req = (KFlashDt*) data;
	KFlashHeadSt rply;
	memset(&rply, 0, sizeof(rply));

	bool q = false;
	rply.status = stOK;
	if (req->Adr + req->dtLen <= UFLASH_SIZE) {
		if (req->dtLen <= MAX_BUF_SIZE) {
			rply.Adr = req->Adr;
			rply.dtLen = req->dtLen;
			trg->addToSend2(dsdDEV_COMMON, msgReadUserFlash, &rply, sizeof(rply), (void*) (baseAdr + rply.Adr), rply.dtLen);
			trg->sendNow();
			q = true;
		} else
			rply.status = stTooBigBuffer;
	} else
		rply.status = stAdrTooBig;
	if (!q) {
		trg->addToSend(dsdDEV_COMMON, msgReadUserFlash, &rply, sizeof(rply));
		trg->sendNow();
	}

}

void DevCommonCmd::readBaseFlash(SvrTargetStream *trg, uint8_t *data, int len) {
	readFlashUni(trg,data,len,FLASH_PROG);
}

void DevCommonCmd::readUserflash(SvrTargetStream *trg, uint8_t *data, int len) {
	readFlashUni(trg,data,len,UFLASH_BASE_ADR);
}


void DevCommonCmd::execUpdate(SvrTargetStream *trg, uint8_t *data, int len) {
	uint32_t m;
	memcpy(&m, data, sizeof(m));
	getOutStream()->oMsgX(colYELLOW, "Start Procedury Kopiującej");
	osDelay(100);
	CopyFlash(FLASH_PROG, UFLASH_BASE_ADR, m);
}

void DevCommonCmd::checkUserFlashClear(SvrTargetStream *trg) {
	KUFlashRply rply;
	memset(&rply, 0, sizeof(rply));
	rply.status = stOK;

	const uint8_t *ptr = (const uint8_t*) (UFLASH_BASE_ADR);
	for (int i = 0; i < UFLASH_SIZE; i++) {
		if (*ptr++ != 0xff) {
			rply.status = stNotClear;
			rply.adr = i;
			break;
		}
	}
	trg->addToSend(dsdDEV_COMMON, msgCheckFlashClear, &rply, sizeof(rply));
	trg->sendNow();
}

bool DevCommonCmd::onReciveCmd(SvrTargetStream *trg, uint8_t cmd, uint8_t *data, int len) {

	switch (cmd) {
	case msgDevInfo: //              // Informacja o karcie
		sendDevInfo(trg);
		break;
	case msgPing:         	       // Ping - odbijanie messagów
		trg->addToSend(dsdDEV_COMMON, cmd, data, len);
		trg->sendNow();
		break;
	case msgExecReset:	           // wykonaj reset karty
		getOutStream()->oMsgX(colYELLOW, "*** R E S E T ***");
		reboot(500);
		break;
	case msgKeepAlive:              // komunikat o poprawnej pracy łącza PC-USB
		trg->addToSend(dsdDEV_COMMON, msgKeepAlive, NULL, 0);
		break;
	case msgGetAuthoBuf:	           // pobranie  bufora do autoryzacji
		sendAuthorBuf(trg);
		break;
	case msgSetAuthoRepl:           // wstawienie bufora autoryzującego

		break;
	case msgSynchTime:              // Synchronizacja czasu

		break;
	case msgGetCfg: {                 // pobranie konfiguracji
		CxBuf *cxBuf = config->getCxBufWithCfgBin();
		trg->addToSend(dsdDEV_COMMON, cmd, cxBuf->mem(), cxBuf->len());
		trg->sendNow();
		free(cxBuf);
	}
		break;
	case msgSetCfg: {                 // ustawienie konfiguracji
		uint8_t st = config->setFromKeyBin(data, len);
		trg->addToSend(dsdDEV_COMMON, cmd, &st, 1);
		trg->sendNow();
	}
		break;
	case msgGetCfgHistory: {
		MemInfo memInfo;
		config->getHistMemInfo(&memInfo);
		trg->addToSend(dsdDEV_COMMON, cmd, memInfo.mem, memInfo.size);
		trg->sendNow();
	}
		break;
	case msgGetSerialNum: {                // pobranie numeru seryjnego
		const char *txt = config->getDevSN();
		trg->addToSend(dsdDEV_COMMON, cmd, txt, strlen(txt));
		trg->sendNow();
	}
		break;

	case msgSetSerialNum: {                 //wysłanie numeru seryjnego
		uint8_t st = config->setSerialNum(data, len);
		trg->addToSend(dsdDEV_COMMON, cmd, &st, 1);
		trg->sendNow();
	}
		break;
	case msgSetTime: {
		TDATE tm;
		memcpy(&tm, data, sizeof(tm));
		if (TimeTools::CheckDtTm(&tm)) {
			char buf[TimeTools::DT_TM_SIZE];
			TimeTools::DtTmStr(buf, &tm);
			getOutStream()->oMsgX(colYELLOW, "SetTime: %s", buf);
			GlobTime::setTm(&tm);
		}

	}
		break;
	case msgClrUserFlash:           // rozkaz kasowania USER flash
		clearUserflash(trg);
		break;
	case msgReadBaseFlash:        // odczyt zawartości głownego flash
		readBaseFlash(trg, data, len);
		break;
	case msgReadUserFlash:          // odczyt zawartości USER Flash
		readUserflash(trg, data, len);
		break;
	case msgWriteUserFlash:         // zapis USER FLASH
		wrtieUserflash(trg, data, len);
		break;
	case msgExecUpdate:             // skopiowanie nowej wersji w aktualnej
		execUpdate(trg, data, len);
		break;
	case msgCheckFlashClear:
		checkUserFlashClear(trg);
		break;

	default:
		return false;

	}
	//msgAddToLog

	return true;
}
