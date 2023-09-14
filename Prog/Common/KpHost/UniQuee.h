/*
 * UniQuee.h
 *
 *  Created on: Oct 8, 2020
 *      Author: Grzegorz
 */

#ifndef UNIQUEE_H_
#define UNIQUEE_H_

class UniQuee {
private:
	size_t FSize;
	char *FBuf;
	volatile size_t FTail;
	volatile size_t FHead;
	bool writehd(const void *ptr, int size);
	bool writehd(char a);
public:
	UniQuee(short size);
	void Clear();
	int Size() {
		return FSize;
	}
	char *Buf() {
		return FBuf;
	}
	int Tail() {
		return FTail;
	}
	int Head() {
		return FHead;
	}
	bool empty();             // czy jest jakiś bajt w kolejce
	int getdatacnt();        // ilośc danych w kolejce
	int getfree();           // ilośc wolnego miejsca w kolejce
	void Beck();

	bool get(char *dt);
	int readln(char *buf, int max);
	int read(char *dst, int cnt);
	int readNoNl(char *buf, int max);
	bool write(const void *ptr, int size);
	bool write(char a);
	void SetHead(int aHead) {
		FHead = aHead;
	}
	void ShowStatus();
};

class Fifo {
private:
	unsigned char *mem;
	int mItemSize;
	int mDeep;
	int mHead;
	int mTail;
public:
	Fifo(int itemSize, int deep);
	bool Push(const void *item);
	bool Pop(void *item);
	bool Empty();
};



#endif /* UNIQUEE_H_ */
