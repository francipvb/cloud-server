# include <config.h>

# define DRIVER		"/kernel/sys/driver"
# define AUTO		"/kernel/lib/auto"

/*
 * privilege levels
 */
# define KERNEL()	sscanf(previous_program(), "/kernel/%*s")
# define SYSTEM()	sscanf(previous_program(), USR_DIR + "/System/%*s")
