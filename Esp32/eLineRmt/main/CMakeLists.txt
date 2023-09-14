# Edit following two lines to set component requirements (see docs)
set(COMPONENT_REQUIRES )
set(COMPONENT_PRIV_REQUIRES )

set(COMPONENT_SRCS  "main.c" 
					"UMain.cpp" 
					"MyConfig.cpp" 
					"TaskClass.cpp" 
					"Shell.cpp"
					"I2C.cpp"
					"I2C.cpp"
					"Base64Tool.cpp"
					"Cpx.cpp"
					"CxBuf.cpp"
					"CxString.cpp"
					"utils.cpp"
					"IOStream.cpp"
					
					"ssd1306.cpp"
					"ssd1306_fonts.c"
					"Max11612.cpp"
					"MyBT.cpp"
					"Token.cpp"
					"UdpScanTask.cpp"
					"TcpSvrTask.cpp"
					"DevCommonCmd.cpp"
					"SensorProcessObj.cpp"
					
					)
set(COMPONENT_ADD_INCLUDEDIRS ".")



register_component()
