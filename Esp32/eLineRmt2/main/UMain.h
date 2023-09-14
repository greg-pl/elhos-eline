/*
 * UMain.h
 *
 *  Created on: 2 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_UMAIN_H_
#define MAIN_UMAIN_H_

class Hdw {
	static bool mV12;
	static bool mKpower;
	static bool mSterOut;

public:
	static void initGPIO();
	static void setKPower(bool q);
	static bool chgKPower();
	static void setSterOut(bool q);
	static bool chgSterOut();
	static void setV12(bool q);
	static bool chgV12();
	static bool getLadStatus();
	static bool getKeyPwr();
};

#endif /* MAIN_UMAIN_H_ */
