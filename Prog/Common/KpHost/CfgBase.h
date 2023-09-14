/*
 * CfgBase.h
 *
 *  Created on: Mar 23, 2021
 *      Author: Grzegorz
 */

#ifndef KPHOST_CFGBASE_H_
#define KPHOST_CFGBASE_H_

#include "myDef.h"
#include "IOStream.h"
#include <Cpx.h>
#include <Utils.h>

#define CFG_REC_MAX_SIZE 0xC00
#define CFG_REC_MAX_SIZE_4 (CFG_REC_MAX_SIZE/4)
#define CFG_HIST_CNT    32
#define SIZE_SERIAL_NR  12
#define SIZE_DEV_NAME   32

#define CFG_REC_SIZE_PRODUCER 0x80
#define CFG_REC_SIZE_HISTORY  0x100

#define CFG_REC_SIZE_USER (CFG_REC_MAX_SIZE - CFG_REC_SIZE_PRODUCER - CFG_REC_SIZE_HISTORY - 0x10)

typedef struct {
	int ID;  //numer kolejny wpisu
	uint16_t keySrvNr;  //numer dongla serwisowego
	uint16_t packedDate;
} HistoryItem;

//256 bajtów
typedef struct __PACKED {
	HistoryItem tab[CFG_HIST_CNT];
} HistoryCfg;

typedef union __PACKED {
	uint8_t buf_p[CFG_REC_SIZE_PRODUCER];
	struct {
		int Sign;
		int size;
		int ver;
		char SerialNr[SIZE_SERIAL_NR];
		char DevID[SIZE_DEV_NAME];
	};
} BaseCfg;



typedef struct {
	void *adr;
	int size;
	const CpxDescr *dscr;
	HistoryCfg *histCfg;
	BaseCfg *baseCfg;

} CfgDataInfo;

class CfgBase {
private:
	CfgDataInfo mDtInfo;
	int FindHistoryNewest();
	void showCfgWrHistory(OutStream *strm);
	void zeroHist();

protected:
	TStatus LoadIntern(uint32_t adr);

protected:
	virtual void getDataInfo(CfgDataInfo *info)=0;
	virtual TStatus CheckCfg()=0;
	virtual void prepareToSave()=0;
	virtual int getJsonSize() {
		return 2000;
	}
	virtual int getCfgBinSize() {
		return 1000;
	}
public:
	CfgBase();
	TStatus Init(OutStream *strm);
	virtual void Zero()=0;
	virtual void Default()=0;
	TStatus save();
	TStatus saveFlash();

	virtual uint32_t getDevInfoSpecDevData(){
		return 0;
	}
	void addHistory(uint16_t packDate, uint16_t keySrvnr);
	TStatus setFromKeyBin(const uint8_t *data,int len);
	void getHistMemInfo(MemInfo *memInfo);
	const char* getSerialNum();
	TStatus  setSerialNum(const void *data, int len);
	CxBuf* getCxBufWithCfgBin();


	void shell(OutStream *strem, const char *cmd);

};

#endif /* KPHOST_CFGBASE_H_ */
