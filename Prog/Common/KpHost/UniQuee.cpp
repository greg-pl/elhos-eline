/*
 * UniQuee.cpp
 *
 *  Created on: Oct 8, 2020
 *      Author: Grzegorz
 */

#include "string.h"
#include "stdio.h"
#include "stdlib.h"
#include "UniQuee.h"

UniQuee::UniQuee(short size) {
	FTail = 0;
	FHead = 0;
	FSize = size;
	FBuf = (char*) malloc(size);
	memset(FBuf, 0, size);
}

void UniQuee::Clear() {
	FTail = 0;
	FHead = 0;
}

#define INC_PTR(w,size)  if(++(w)==size) w=0

bool UniQuee::writehd(char a) {
	size_t n = FHead;
	INC_PTR(n, FSize);
	if (n == FTail)
		return (false);
	FBuf[FHead] = a;
	FHead = n;
	return true;
}

bool UniQuee::write(char a) {
	return writehd(a);
}

bool UniQuee::writehd(const void *ptr, int size) {
	int free, cnt1;
	size_t _Tail, _Head;
	const unsigned char *p;

	_Tail = FTail;
	_Head = FHead;
	p = (const unsigned char*) ptr;

	free = _Tail - _Head - 1;
	if (free < 0)
		free += FSize;
	if (free < size)
		return false;

	if (_Tail > _Head) {  //jeden kawałek
		memcpy(&FBuf[_Head], p, size);
		_Head += size;
	} else {
		cnt1 = FSize - _Head;
		if (size < cnt1)
			cnt1 = size;
		memcpy(&FBuf[_Head], p, cnt1);
		size -= cnt1;
		_Head += cnt1;
		if (_Head >= FSize)
			_Head -= FSize;
		if (size != 0) {
			p += cnt1;
			memcpy(&FBuf[_Head], p, size);
			_Head += size;
		}
	}
	FHead = _Head;
	return true;
}

bool UniQuee::write(const void *ptr, int size) {
	return writehd(ptr, size);
}

bool UniQuee::empty() {
	return (FHead == FTail);
}

bool UniQuee::get(char *dt) {
	if (FHead == FTail)
		return (false);
	*dt = FBuf[FTail];
	INC_PTR(FTail, FSize);
	return (true);
}

void UniQuee::Beck() {

	size_t n = FTail;
	if (n == 0)
		n = FSize;
	n--;
	if (n != FHead)
		FTail = n;
}

int UniQuee::getfree() {
	int free = FTail - FHead - 1;
	if (free < 0)
		free += FSize;
	return free;
}

int UniQuee::getdatacnt() {
	int cnt = FHead - FTail;
	if (cnt < 0)
		cnt += FSize;
	return (cnt);
}

// zwraca:
//   -1 jesli brak danych
//   dlugosc danych skopiowanych do bufora
int UniQuee::readln(char *buf, int max) {

	size_t wsk = FTail;
	int n = 0;
	while (1) {
		if (wsk == FHead) {
			wsk = FTail;
			INC_PTR(wsk, FSize);
			if (wsk == FHead) {
				FTail = FHead;
			}
			return -1;
		}
		char a = FBuf[wsk];
		if (n < max - 2) {
			buf[n++] = a;
		}
		INC_PTR(wsk, FSize);
		if (a == '\n') {
			break;
		}
	}
	FTail = wsk;
	buf[n] = 0;
	return n;
}

int UniQuee::readNoNl(char *buf, int max) {
	int n = readln(buf, max);
	if (n >= 2 && buf[n - 2] == '\r' && buf[n - 1] == '\n') {
		buf[n - 2] = 0;
		return n - 2;
	} else
		return 0;
}

int UniQuee::read(char *dst, int cnt) {
	int datacnt;
	int cnt1, cnt2;

	datacnt = getdatacnt();
	if (datacnt == 0) {
		return (0);
	}

	if (cnt == 1) {
		dst[0] = (char) FBuf[FTail];
		INC_PTR(FTail, FSize);
		return (1);
	}
	if (datacnt < cnt)
		cnt = datacnt;
	cnt2 = cnt;

	if (FTail + cnt < FSize) {
		memcpy(dst, &FBuf[FTail], cnt);
		FTail += cnt;
	} else {
		cnt1 = FSize - FTail;
		memcpy(dst, &FBuf[FTail], cnt1);
		cnt -= cnt1;
		dst += cnt1;
		FTail = 0;
		if (cnt != 0) {
			memcpy(dst, &FBuf[FTail], cnt);
			FTail += cnt;
		}
	}
	return (cnt2);
}

void UniQuee::ShowStatus() {
	//printf("H=%u T=%u Cnt=%u",FHead,FTail,FSize);
	printf("H=%u T=%u", FHead, FTail);
}

//--------------------------------------------------------
// Fifo
//--------------------------------------------------------
Fifo::Fifo(int itemSize, int deep) {
	int sz = itemSize * deep;
	mem = (unsigned char*) malloc(sz);
	mItemSize = itemSize;
	mDeep = deep;
	mHead = 0;
	mTail = 0;
}
bool Fifo::Empty() {
	return (mHead == mTail);
}

bool Fifo::Push(const void *item) {
	int h = mHead + 1;
	if (h == mDeep)
		h = 0;
	if (h != mTail) {
		unsigned char *ptr = &mem[mHead * mItemSize];
		memcpy(ptr, item, mItemSize);
		mHead = h;
		return true;
	} else
		return false;
}

bool Fifo::Pop(void *item) {
	if (mHead != mTail) {
		unsigned char *ptr = &mem[mTail * mItemSize];
		memcpy(item, ptr, mItemSize);
		if (++mTail == mDeep)
			mTail = 0;
		return true;
	} else
		return false;
}

