/*
 * Cpx.h
 *
 *  Created on: Dec 11, 2020
 *      Author: Grzegorz
 */

#ifndef CPX_H_
#define CPX_H_

#include "lwip/sys.h"
#include "lwip/ip4_addr.h"
#include "lwip/ip_addr.h"

#include "stdint.h"
#include "ErrorDef.h"

#include <IOStream.h>
#include <CxString.h>
#include <CxBuf.h>

typedef enum {
	cpxNULL, //
	cpxCHILD, //
	cpxSTR, //
	cpxQUOTASTR, //
	cpxBOOL, //
	cpxBYTE, //
	cpxWORD, //
	cpxHEXWORD, //
	cpxINT, //
	cpxFLOAT, //
	cpxIP, //
	cpxTIME, //
} CpxType;

typedef struct {
	CpxType ctype;
	int id;
	uint32_t ofs;
	const char *Name;
	int size; // Wartość 0 odpowiada wartości 1
	const void *exPtr;
} CpxDescr;

#define flagSHOWBR   0x0001  //przed listowaniem pokaz linie rozdzielająca
typedef struct {
	int itemCnt;
	int itemSize;
	const CpxDescr *defs;
	uint32_t flags;
} CpxChildInfo;

typedef struct {
	CpxDescr descr;
	void *data;
} FndRes;

typedef const char* (*FunCpxFloatGetFrm)(int idx);

class IdHist {
	bool mAddNum;
	int mDeep;
	uint8_t *mem;
	int mPtr;
	int mIdx;
public:
	IdHist(bool addNum, int deep);
	~IdHist();
	void add(int id);
	void delLast();
	void buildStr(CxString *cstr);
	void fillHistBin(CxBuf *cxBuf);

	void loadfromStr(const char *txt);
	void loadfromMem(const uint8_t *dt);

	int getIDX() {
		return mem[mIdx];
	}
	bool isLastIdx() {
		return (mIdx == mPtr - 1);
	}
	void next();
	void prev();
	bool isAdd(){
		return mAddNum;
	}
};

class Cpx {
private:
	enum {
		WBUF_SIZE = 160,
	};
	const CpxDescr *mDef;
	void *mData;
	static bool findS(CxString *token, Cpx *result, const CpxDescr *aDef, void *aData, const char *name);
	static bool findS(Cpx *result, const CpxDescr *aDef, void *aData, IdHist *idHist);
	static bool set(const Cpx *itemToSet, const char *txt);
	static bool setBin(const Cpx *itemToSet, const uint8_t *val, uint8_t dt_sz);
	static void getAsTxt(const CpxDescr *def, const void *data, char *buf, int max);

	bool find(Cpx *result, const char *name);
	bool find(Cpx *result, IdHist *idHist);

	void showDef(OutStream *strm, const CpxDescr *def, char *wBuf, char *space);
	void list(OutStream *strm, CxString *wstr, CxString *front, IdHist *keyHist, int idx);
	void buildjson(CxString *out, char *space, int idx, uint8_t flags);
	void buildBinCfg(CxBuf *cxBuf,IdHist *idHist);
public:
	void init(const CpxDescr *aDef, const void *aData);
	bool set(const char *name, const char *val);
	bool setk(const char *idStr, const char *val);
	bool setm(const uint8_t *idMem, const uint8_t *val, uint8_t dt_sz);

	void list(OutStream *strm);
	void listk(OutStream *strm);
	void showDef(OutStream *strm);
	void buildjson(CxString *outStr);
	void getAsTxt(char *buf, int max);
	void getAsTxt(CxString *cstr);
	void buildBinCfg(CxBuf *cxBuf);
	TStatus InsertChanges(OutStream *strm, const uint8_t *data, int len);
	static void BuildKeyStr(char *txt, int max, const uint8_t *key);
	void show(const char *caption);




public:
	static int atoi_hex(const char *txt);

};

#endif /* CPX_H_ */
