function(check_perl_module RESULT_VAR MODULE_NAME)
	execute_process(
		COMMAND "${PERL_EXECUTABLE}" "-M${MODULE_NAME}" -e ""
		ERROR_QUIET RESULT_VARIABLE perl_result
	)

	if(perl_result)
		set(${RESULT_VAR} FALSE PARENT_SCOPE)
	else()
		set(${RESULT_VAR} TRUE PARENT_SCOPE)
	endif()
endfunction()

function(check_perl_modules RESULT_VAR)
	set(result "")
	foreach(module ${ARGN})
		check_perl_module(module_found ${module})
		if(NOT module_found)
			list(APPEND result ${module})
		endif()
	endforeach()
	set(${RESULT_VAR} ${result} PARENT_SCOPE)
endfunction()
