/*
 * Cpx.cpp
 *
 *  Created on: Dec 11, 2020
 *      Author: Grzegorz
 */

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include <Cpx.h>
#include <utils.h>
#include <Token.h>

IdHist::IdHist(bool addNum, int deep) {
	mAddNum = addNum;
	mDeep = deep;
	mem = (uint8_t*) malloc(deep * sizeof(mem[0]));
	mPtr = 0;
}

IdHist::~IdHist() {
	free(mem);
}

void IdHist::add(int id) {
	if (mPtr < mDeep) {
		mem[mPtr++] = id;
	}
}
void IdHist::delLast() {
	if (mPtr > 0)
		mPtr--;
}

void IdHist::buildStr(CxString *cstr) {
	if (mAddNum) {
		if (mPtr > 1) {
			for (int i = 0; i < mPtr - 1; i++) {
				cstr->addFormat("%u.", mem[i]);
			}
		}
		cstr->addFormat("%u ", mem[mPtr - 1]);
	}
}

void IdHist::fillHistBin(CxBuf *cxBuf) {
	for (int i = 0; i < mPtr; i++) {
		cxBuf->addByte(mem[i]);
	}
	cxBuf->addByte(0);
}

void IdHist::next() {
	if (mIdx < mPtr)
		mIdx++;

}
void IdHist::prev() {
	if (mIdx > 0)
		mIdx--;

}

void IdHist::loadfromStr(const char *txt) {
	mPtr = 0;
	while (1) {
		int a;
		if (!Token::getAsInt(&txt, ".", &a))
			break;
		if (mPtr < mDeep) {
			mem[mPtr++] = a;
		}
	}
	mIdx = 0;
}

void IdHist::loadfromMem(const uint8_t *dt) {
	mPtr = 0;
	while (*dt && mPtr < mDeep) {
		mem[mPtr++] = *dt++;
	}
	mIdx = 0;
}

void Cpx::init(const CpxDescr *aDef, const void *aData) {
	mDef = aDef;
	mData = (void*) (int) aData;
}

bool Cpx::find(CxString *token, Cpx *result, const CpxDescr *aDef, void *aData, const char *name) {

	char sep;
	char *tok = token->p();

	Token::get(&name, " .[]", tok, token->size(), NULL, &sep);

	while (aDef->ctype != cpxNULL) {
		if (strcmp(aDef->Name, tok) == 0) {
			if (aDef->ctype != cpxCHILD) {
				if (name[0] == 0) {
					result->init(aDef, aData);
					return true;
				} else
					return false;
			} else {
				const CpxChildInfo *chInfo = (const CpxChildInfo*) aDef->exPtr;
				uint8_t *dt = (uint8_t*) aData;
				dt += aDef->ofs;
				if (sep == '[') {
					int idx;
					if (Token::getAsInt(&name, " .[]", &idx)) {
						if (name[0] == ']' && name[1] == '.') {
							name++;
							if (idx < chInfo->itemCnt) {
								dt += (idx * chInfo->itemSize);
								return find(token, result, chInfo->defs, dt, name);
							}
						}

					}
				} else {
					if (chInfo->itemCnt == 0 || chInfo->itemCnt == 1) {
						return find(token, result, chInfo->defs, dt, name);
					}
				}
				return false;
			}
		}
		aDef++;
	}
	return false;

}

bool Cpx::find(Cpx *result, const char *name) {
	CxString *token = new CxString(100);
	bool q = find(token, result, mDef, mData, name);
	delete token;
	return q;
}

bool Cpx::find(Cpx *result, const CpxDescr *aDef, void *aData, IdHist *idHist) {

	int id = idHist->getIDX();
	while (aDef->ctype != cpxNULL) {
		if (aDef->id == id) {
			if (aDef->ctype != cpxCHILD) {
				if (idHist->isLastIdx()) {
					result->init(aDef, aData);
					return true;
				} else
					return false;
			} else {
				const CpxChildInfo *chInfo = (const CpxChildInfo*) aDef->exPtr;
				uint8_t *dt = (uint8_t*) aData;
				dt += aDef->ofs;
				int n = chInfo->itemCnt;
				if (n == 0)
					n = 1;
				if (n > 1) {
					idHist->next();
					int idTab = idHist->getIDX() - 1;
					if (idTab >= 0 && idTab < n) {
						idHist->next();
						dt += (idTab * chInfo->itemSize);
						return find(result, chInfo->defs, dt, idHist);
					}

				} else {
					idHist->next();
					return find(result, chInfo->defs, dt, idHist);
				}
				return false;
			}
		}
		aDef++;
	}
	return false;
}

bool Cpx::find(Cpx *result, IdHist *idHist) {
	return find(result, mDef, mData, idHist);
}

bool Cpx::set(const char *name, const char *txt) {
	Cpx fndRes;

	if (!find(&fndRes, name))
		return false;
	return set(&fndRes, txt);
}

bool Cpx::setk(const char *idStr, const char *val) {
	IdHist *idHist = new IdHist(false, 10);
	idHist->loadfromStr(idStr);

	Cpx fndRes;
	if (!find(&fndRes, idHist))
		return false;
	return set(&fndRes, val);

}

//ustawienie nastawy za pomoca klucza binarnego
bool Cpx::setm(const uint8_t *idMem, const uint8_t *val, uint8_t dt_sz) {
	IdHist *idHist = new IdHist(false, 10);
	idHist->loadfromMem(idMem);

	Cpx fndRes;
	if (!find(&fndRes, idHist))
		return false;
	return setBin(&fndRes, val, dt_sz);
}

int Cpx::atoi_hex(const char *txt) {
	if (txt[0] == '0' && (txt[1] == 'x' || txt[1] == 'X')) {
		return strtol(txt, NULL, 16);
	} else {
		return atoi(txt);
	}

}
bool Cpx::setBin(const Cpx *itemToSet, const uint8_t *src, uint8_t dt_sz) {

	const CpxDescr *def = itemToSet->mDef;
	uint32_t adr = (uint32_t) itemToSet->mData;

	void *dst = (void*) (adr + def->ofs);

	switch (def->ctype) {
	case cpxNULL:
		return false;
	case cpxSTR:
		if (dt_sz>def->size-1)
			dt_sz=def->size-1;
		strncpy((char*) dst, (const char*) src, dt_sz);
		((char*) dst)[dt_sz] = 0;
		break;
	case cpxQUOTASTR:
		Token::copyNoQuota((char*) dst, def->size, (const char*) src);
		break;
	case cpxBOOL:
		*(bool*) dst = *(bool*) src;
		break;

	case cpxBYTE:
		*(uint8_t*) dst = *(uint8_t*) src;
		break;
	case cpxHEXWORD:
	case cpxWORD:
		*(uint16_t*) dst = *(uint16_t*) src;
		break;

	case cpxINT:
		*(int*) dst = *(int*) src;
		break;
	case cpxFLOAT:
		*(float*) dst = *(float*) src;
		break;

	case cpxIP:
		*(ip4_addr_t*) dst = *(ip4_addr_t*) src;
		break;
	case cpxTIME:
		*(TDATE*) dst = *(TDATE*) src;
		break;
	case cpxCHILD:
		//CHILD nie powinien tu dotrzeć
		break;
	}

	return true;
}

bool Cpx::set(const Cpx *itemToSet, const char *txt) {

	const CpxDescr *def = itemToSet->mDef;
	uint32_t adr = (uint32_t) itemToSet->mData;

	void *ptr = (void*) (adr + def->ofs);

	switch (def->ctype) {
	case cpxNULL:
		return false;
	case cpxSTR: {
		char *dst = (char*) ptr;
		strncpy(dst, txt, def->size);
		dst[def->size - 1] = 0;
	}
	case cpxQUOTASTR: {
		char *dst = (char*) ptr;
		Token::copyNoQuota(dst, def->size, txt);
	}
		break;
	case cpxBOOL: {
		bool *pb = (bool*) ptr;
		*pb = atoi(txt);
	}
		break;

	case cpxBYTE: {
		uint8_t *pb = (uint8_t*) ptr;
		*pb = atoi_hex(txt);
	}
		break;
	case cpxHEXWORD:
	case cpxWORD: {
		uint16_t *pb = (uint16_t*) ptr;
		*pb = atoi_hex(txt);
	}
		break;

	case cpxINT: {
		int *pi = (int*) ptr;
		*pi = atoi_hex(txt);
	}
		break;
	case cpxFLOAT: {
		float *pf = (float*) ptr;
		*pf = atof(txt);
	}
		break;

	case cpxIP: {
		ip4_addr_t *pf = (ip4_addr_t*) ptr;
		return ipaddr_aton(txt, pf);
	}
		break;
	case cpxTIME: {
		TDATE *tm = (TDATE*) ptr;
		const char *ptr = txt;
		TimeTools::parseDate(&ptr, tm);
		TimeTools::parseTime(&ptr, tm);
	}
		break;
	case cpxCHILD:
		//CHILD nie powinien tu dotrzeć
		break;
	}

	return true;
}

const char *const ctypeNameTab[] = {
		"NULL", //
		"CHILD", //
		"STR", //
		"QUOTASTR", //
		"BOOL", //
		"BYTE", //
		"WORD", //
		"HEXWORD", //
		"INT", //
		"FLOAT", //
		"IP"
		"TIME" };

const char* getCodeName(CpxType typ) {
	int N = sizeof(ctypeNameTab) / sizeof(ctypeNameTab[0]);
	if (typ < N)
		return ctypeNameTab[typ];
	else
		return "<?>";
}

void Cpx::showDef(OutStream *strm, const CpxDescr *def, char *wBuf, char *space) {
	while (def->ctype != cpxNULL) {
		const CpxChildInfo *grInfo = NULL;
		int n = snprintf(wBuf, WBUF_SIZE, "%styp=%s ofs=%u name=[%s] size=%u", space, getCodeName(def->ctype), (int) def->ofs, def->Name, def->size);

		switch (def->ctype) {
		case cpxFLOAT:
			if (def->exPtr != NULL) {
				FunCpxFloatGetFrm fun = (FunCpxFloatGetFrm) (def->exPtr);
				const char *frm = fun(0);
				n += snprintf(&wBuf[n], WBUF_SIZE - n, " Frm=[%s]", frm);
			}
			break;
		case cpxCHILD:
			grInfo = (const CpxChildInfo*) def->exPtr;
			n += snprintf(&wBuf[n], WBUF_SIZE - n, " N=%u sz=%u", grInfo->itemCnt, grInfo->itemSize);
			break;
		default:
			break;
		}
		strm->oWr(wBuf);
		if (def->ctype == cpxCHILD) {
			int m = strlen(space);
			space[m + 0] = ' ';
			space[m + 1] = ' ';
			space[m + 2] = 0;
			showDef(strm, grInfo->defs, wBuf, space);
			space[m] = 0;
		}
		def++;
	}

}

void Cpx::showDef(OutStream *strm) {
	if (strm->oOpen(colWHITE)) {
		char spaceStr[40];
		char wbuf[WBUF_SIZE];
		spaceStr[0] = 0;
		showDef(strm, mDef, wbuf, spaceStr);
		strm->oClose();
	}
}

void Cpx::getAsTxt(const CpxDescr *def, const void *data, char *buf, int max) {
	void *ptr = (void*) ((uint32_t) data + def->ofs);

	switch (def->ctype) {
	case cpxSTR:
		snprintf(buf, max, (char*) ptr);
		break;
	case cpxQUOTASTR:
		Token::setQuotaStr(buf, (const char*) ptr, max);
		break;

	case cpxBOOL:
		snprintf(buf, max, "%u", *(bool*) ptr);
		break;
	case cpxBYTE:
		snprintf(buf, max, "%u", *(uint8_t*) ptr);
		break;
	case cpxHEXWORD:
		snprintf(buf, max, "0X%04X", *(uint16_t*) ptr);
		break;
	case cpxWORD:
		snprintf(buf, max, "%u", *(uint16_t*) ptr);
		break;
	case cpxINT:
		snprintf(buf, max, "%u", *(int*) ptr);
		break;
	case cpxFLOAT: {
		const char *frm = "%f";
		if (def->exPtr != NULL) {
			FunCpxFloatGetFrm fun = (FunCpxFloatGetFrm) (def->exPtr);
			frm = fun(0);
		}
		snprintf(buf, max, frm, (double) (*(float*) ptr));
	}
		break;

	case cpxIP:
		ipaddr_ntoa_r((ip4_addr_t* ) ptr, buf, max);
		break;
	case cpxTIME: {
		const TDATE *tm = (const TDATE*) ptr;
		char tmBuf[20];
		TimeTools::DtTmStr(tmBuf, tm);
		snprintf(buf, max, tmBuf);
	}
		break;

	default:
		break;
	}

}

void Cpx::getAsTxt(char *buf, int max) {
	getAsTxt(mDef, mData, buf, max);
}

void Cpx::getAsTxt(CxString *cstr) {
	getAsTxt(mDef, mData, cstr->resP(), cstr->restSize());
	cstr->buildLen();
}

void Cpx::list(OutStream *strm, CxString *wstr, CxString *front, IdHist *idHist, int idx) {

	const CpxDescr *def = mDef;
	int m1 = front->len();

	while (def->ctype != cpxNULL) {
		front->setLen(m1);

		idHist->add(def->id);

		wstr->clear();
		if (idHist->isAdd()) {
			idHist->buildStr(wstr);
			wstr->fillSpaces(11);
		}

		front->add(def->Name);
		wstr->add(front);
		wstr->add(":");

		void *ptr = (void*) ((uint32_t) mData + def->ofs);

		bool showWstr = true;
		switch (def->ctype) {
		case cpxSTR:
			wstr->add((char*) ptr);
			break;
		case cpxQUOTASTR:
			wstr->addQuota((const char*) ptr);
			break;

		case cpxBOOL:
			wstr->addFormat("%u", (int) (*(bool*) ptr));
			break;
		case cpxBYTE:
			wstr->addFormat("%u", (int) (*(uint8_t*) ptr));
			break;
		case cpxWORD:
			wstr->addFormat("%u", (int) (*(uint16_t*) ptr));
			break;
		case cpxHEXWORD:
			wstr->addFormat("0X%04X", (int) (*(uint16_t*) ptr));
			break;
		case cpxINT:
			wstr->addFormat("%d", (int) (*(int*) ptr));
			break;
		case cpxFLOAT: {
			const char *frm = "%f";
			if (def->exPtr != NULL) {
				FunCpxFloatGetFrm fun = (FunCpxFloatGetFrm) (def->exPtr);
				frm = fun(idx);
			}
			wstr->addFormat(frm, (*(float*) ptr));
		}
			break;

		case cpxIP: {
			ip4_addr_t *pf = (ip4_addr_t*) ptr;
			char txt[20];
			ipaddr_ntoa_r(pf, txt, sizeof(txt));
			wstr->add(txt);
		}
			break;
		case cpxTIME: {
			const TDATE *tm = (const TDATE*) ptr;
			char txt[20];
			TimeTools::DtTmStr(txt, tm);
			wstr->add(txt);
		}
			break;

		case cpxCHILD: {
			showWstr = false;

			const CpxChildInfo *chInfo = (const CpxChildInfo*) def->exPtr;
			if ((chInfo->flags & flagSHOWBR) != 0) {
				strm->oMsg("--- %s ----------------------", def->Name);
			}

			int m2 = front->len();
			uint8_t *dt = (uint8_t*) ptr;
			for (int k = 0; k < chInfo->itemCnt; k++) {
				front->setLen(m2);
				if (chInfo->itemCnt > 1) {
					front->addFormat("[%u].", k);
					idHist->add(k + 1);
				} else {
					front->add(".");
				}

				Cpx child;
				child.init(chInfo->defs, dt);
				child.list(strm, wstr, front, idHist, k);

				if (chInfo->itemCnt > 1) {
					idHist->delLast();
				}

				dt += chInfo->itemSize;
			}
		}
			break;

		default:
			break;
		}
		if (showWstr)
			strm->oMsg(wstr->p());

		idHist->delLast();
		def++;
	}
}

void Cpx::list(OutStream *strm) {
	if (strm->oOpen(colWHITE)) {
		CxString *front = new CxString(200);
		CxString *wstr = new CxString(300);
		IdHist *idHist = new IdHist(false, 10);
		list(strm, wstr, front, idHist, 0);
		delete idHist;
		delete wstr;
		delete front;
		strm->oClose();
	}
}

void Cpx::listk(OutStream *strm) {
	if (strm->oOpen(colWHITE)) {
		CxString *front = new CxString(200);
		CxString *wstr = new CxString(300);
		IdHist *idHist = new IdHist(true, 10);
		list(strm, wstr, front, idHist, 0);
		delete idHist;
		delete wstr;
		delete front;
		strm->oClose();
	}
}

void Cpx::buildBinCfg(CxBuf *cxBuf, IdHist *idHist) {

	const CpxDescr *def = mDef;

	while (def->ctype != cpxNULL) {

		idHist->add(def->id);

		void *ptr = (void*) ((uint32_t) mData + def->ofs);

		if (def->ctype != cpxCHILD) {

			int memPtr = cxBuf->len();
			cxBuf->addByte(0); // miejsce na size
			idHist->fillHistBin(cxBuf);

			switch (def->ctype) {
			case cpxSTR:
			case cpxQUOTASTR:
				cxBuf->addStr((char*) ptr, def->size);
				break;

			case cpxBOOL:
			case cpxBYTE:
				cxBuf->add(ptr, 1);
				break;
			case cpxHEXWORD:
			case cpxWORD:
				cxBuf->add(ptr, 2);
				break;
			case cpxINT:
			case cpxFLOAT:
			case cpxIP:
				cxBuf->add(ptr, 4);
				break;
			case cpxTIME:
				cxBuf->add(ptr, sizeof(TDATE));
				break;
			default:
				break;

			}
			int sz = cxBuf->len() - memPtr;
			cxBuf->replace(memPtr, sz);
		} else {
			// cpxCHILD:
			const CpxChildInfo *chInfo = (const CpxChildInfo*) def->exPtr;

			uint8_t *dt = (uint8_t*) ptr;
			for (int k = 0; k < chInfo->itemCnt; k++) {

				if (chInfo->itemCnt > 1) {
					idHist->add(k + 1);
				}

				Cpx child;
				child.init(chInfo->defs, dt);
				child.buildBinCfg(cxBuf, idHist);

				if (chInfo->itemCnt > 1) {
					idHist->delLast();
				}
				dt += chInfo->itemSize;
			}
		}
		idHist->delLast();
		def++;
	}

}

void Cpx::buildBinCfg(CxBuf *cxBuf) {
	IdHist *idHist = new IdHist(true, 10);
	buildBinCfg(cxBuf, idHist);
	delete idHist;
}

void Cpx::BuildKeyStr(char *txt, int max, const uint8_t *key) {

	int n = 0;
	while (*key) {
		if (n != 0 && n < max - 1)
			txt[n++] = ',';
		n += snprintf(&txt[n], max - n, "%u", *key);
		key++;
	}

}

TStatus Cpx::InsertChanges(OutStream *strm, const uint8_t *data, int len) {
	int ptr = 0;

	TStatus st = stOK;
	while (ptr < len) {
		uint8_t n = data[ptr];
		if (ptr + n > len) {
			break;
		}
		int n1 = strlen((char*)&data[ptr + 1]);
		const uint8_t *key = &data[ptr + 1];
		const uint8_t *dt = &data[ptr + 1 + n1 + 1];
		uint8_t dt_sz = len-(2+n1);

		char ktxt[80];

		BuildKeyStr(ktxt, sizeof(ktxt), key);

		if (setm(key, dt,dt_sz)) {
			strm->oMsgX(colCYAN, "Wstawiono cfg <%s>",ktxt);
		} else {
			strm->oMsgX(colCYAN, "Błąd wstawiania cfg <%s>" ,ktxt);
			st = stCfgDataErr;
			break;
		}
		ptr += n;
	}
	return st;
}

#define JSON_NL "\r\n"
#define JSON_SPACE1 "    "

#define flagSINGLECHILD 0x01
#define flagLAST  0x02
#define flagMORE	0x04

void Cpx::buildjson(CxString *out, char *space, int idx, uint8_t flags) {
	const CpxDescr *def = mDef;

	if (flags & flagMORE)
		out->add(JSON_NL);

	if (!(flags & flagSINGLECHILD))
		out->add(space);
	out->add("{" JSON_NL);

	int spM = strlen(space);
	strcat(space, JSON_SPACE1);

	bool firstItem = true;
	while (def->ctype != cpxNULL) {

		void *ptr = (void*) ((uint32_t) mData + def->ofs);

		if (out->isFull())
			return;

		bool addItem = true;
		switch (def->ctype) {
		case cpxFLOAT: {
			float *pf = (float*) ptr;
			float f = *pf;
			if (isnanf(f))
				addItem = false;
		}
			break;
		default:
			break;
		}

		if (addItem) {
			if (firstItem) {
				firstItem = false;
			} else {
				// kończenie poprzedniej linii
				out->add("," JSON_NL);
				if (out->isFull())
					return;
			}

			out->addFormat("%s\"%s\": ", space, def->Name);
			if (out->isFull())
				return;

			switch (def->ctype) {
			case cpxQUOTASTR:
			case cpxSTR:
				out->addQuota((char*) ptr);
				break;

			case cpxBOOL: {
				bool *pb = (bool*) ptr;
				out->addFormat("%s", FalseTrue(*pb));
			}
				break;
			case cpxBYTE: {
				uint8_t *pb = (uint8_t*) ptr;
				out->addFormat("%u", *pb);
			}
				break;
			case cpxWORD: {
				uint16_t *pb = (uint16_t*) ptr;
				out->addFormat("%u", *pb);
			}
				break;
			case cpxHEXWORD: {
				uint16_t *pb = (uint16_t*) ptr;
				out->addFormat("0X%04X", *pb);
			}
				break;
			case cpxINT: {
				int *pi = (int*) ptr;
				out->addFormat("%u", *pi);
			}
				break;
			case cpxFLOAT: {
				const char *frm = "%f";
				if (def->exPtr != NULL) {
					FunCpxFloatGetFrm fun = (FunCpxFloatGetFrm) (def->exPtr);
					frm = fun(idx);
				}
				float *pf = (float*) ptr;
				out->addFormat(frm, *pf);
			}
				break;

			case cpxIP: {
				ip4_addr_t *pf = (ip4_addr_t*) ptr;
				char txt[20];
				ipaddr_ntoa_r(pf, txt, sizeof(txt));
				out->addQuota(txt);
			}
				break;
			case cpxTIME: {
				const TDATE *tm = (const TDATE*) ptr;
				char tmBuf[20];
				TimeTools::DtTmStr(tmBuf, tm);
				out->addFormat("\"%s\"", tmBuf);
			}
				break;

			case cpxCHILD: {
				const CpxChildInfo *grInfo = (const CpxChildInfo*) def->exPtr;

				int n = grInfo->itemCnt;
				if (n == 0)
					n = 1;

				int spMM = strlen(space);
				if (n > 1) {
					out->add("[" JSON_NL);
					strcat(space, JSON_SPACE1);
				}

				uint8_t *dt = (uint8_t*) ptr;

				for (int ii = 0; ii < n; ii++) {
					Cpx child;
					child.init(grInfo->defs, dt);
					uint8_t chFlags = 0;
					if (n == 1)
						chFlags |= flagSINGLECHILD;
					if (ii == grInfo->itemCnt - 1)
						chFlags |= flagLAST;
					if (ii > 0)
						chFlags |= flagMORE;

					child.buildjson(out, space, ii, chFlags);
					dt += grInfo->itemSize;
					if (out->isFull())
						return;
				}
				space[spMM] = 0;
				if (n > 1) {
					out->addFormat(JSON_NL "%s]", space);
				} else {

				}
			}
				break;

			default:
				break;
			}
		}
		def++;
		if (out->isFull())
			break;
	}
	out->add(JSON_NL); //zamykanie ostatniej linii
	if (out->isFull())
		return;

	const char *p = "";
	if ((flags & flagLAST) == 0)
		p = ",";

	space[spM] = 0;

	out->addFormat("%s}%s", space, p);
}

void Cpx::buildjson(CxString *outStr) {
	char spaceStr[40];
	spaceStr[0] = 0;
	buildjson(outStr, spaceStr, 0, flagLAST);
	outStr->add(JSON_NL);

}

