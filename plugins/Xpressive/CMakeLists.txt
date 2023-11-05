INCLUDE(BuildPlugin)

INCLUDE_DIRECTORIES(exprtk)
ADD_COMPILE_DEFINITIONS(
	exprtk_disable_sc_andor
	exprtk_disable_return_statement
	exprtk_disable_break_continue
	exprtk_disable_comments
	exprtk_disable_string_capabilities
	exprtk_disable_rtl_io_file
	exprtk_disable_rtl_vecops
)
ADD_COMPILE_OPTIONS(${WERROR_FLAGS} -fexceptions)

IF(LMMS_BUILD_WIN32 AND NOT MSVC)
	ADD_COMPILE_OPTIONS(-Wa,-mbig-obj)
	ADD_COMPILE_DEFINITIONS(exprtk_disable_enhanced_features)
ELSEIF(LMMS_BUILD_WIN32 AND MSVC)
	ADD_COMPILE_OPTIONS(/bigobj)
ENDIF()

BUILD_PLUGIN(xpressive
	Xpressive.cpp
	ExprSynth.cpp
	Xpressive.h
	exprtk/exprtk.hpp
	MOCFILES Xpressive.h
	EMBEDDED_RESOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.png"
)
