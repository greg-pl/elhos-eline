# Edit following two lines to set component requirements (see docs)
#set(COMPONENT_REQUIRES )
#set(COMPONENT_PRIV_REQUIRES )
#set(COMPONENT_SRCS "main.c" "UMain.cpp" "MyConfig.cpp" "TaskClass.cpp" "Shell.cpp")
#set(COMPONENT_ADD_INCLUDEDIRS  ".")
#register_component()

idf_component_register(SRCS "main.c" 
							"UMain.cpp" 
							"MyConfig.cpp" 
							"TaskClass.cpp" 
							"Shell.cpp"
							"I2C.cpp"
                    INCLUDE_DIRS ".")
