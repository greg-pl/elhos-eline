/*
 * MyConfig.h
 *
 *  Created on: 1 kwi 2021
 *      Author: Grzegorz
 */

#ifndef MAIN_MYCONFIG_H_
#define MAIN_MYCONFIG_H_

typedef struct {
	char WifiSSID[32];
	char WifiPassword[32];

} CfgData;

class MyConfig {
public:
	CfgData data;
	MyConfig();
	virtual ~MyConfig();
	void init();
	void defaultCfg();
	void write();


};

#endif /* MAIN_MYCONFIG_H_ */
