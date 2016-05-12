/*
 * Copyright (c) 2014 Sebastian Reichel <sre@kernel.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published by
 * the Free Software Foundation.
 */

#ifndef _TOUCHSCREEN_H
#define _TOUCHSCREEN_H

#include <asm/types.h>

struct input_dev;

struct touchscreen_properties {
	s32 max_x;
	s32 max_y;
	bool invert_x;
	bool invert_y;
	bool swap_x_y;
};

void touchscreen_parse_properties(struct input_dev *input, bool multitouch,
				  struct touchscreen_properties *prop);

void touchscreen_apply_prop_to_x_y(struct touchscreen_properties *prop,
				   s16 *x, s16 *y);

#endif
