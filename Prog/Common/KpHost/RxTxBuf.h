/*
 * RxTxBuf.h
 *
 *  Created on: Jun 14, 2021
 *      Author: Grzegorz
 */

#ifndef RXTXBUF_H_
#define RXTXBUF_H_
//------------------------------------------------------------------------------------------------------------
typedef struct{
	const char *dt;
	int len;
}Portion;

class RxTxBuf {
private:
	volatile int mHead;
	volatile int mTail;
	volatile int mLockRegionTail;
	int mSize;
	int getFree();
public:
	char *mBuf;
	RxTxBuf(int size);
	void clear();
	bool addBuf(Portion *portion);
	bool add(char ch);
	bool readLn(char *buf, int max);
	bool lockLinearRegion(const char **pptr, int *cnt, int max);
	void unlockRegion();
};

#endif /* RXTXBUF_H_ */
