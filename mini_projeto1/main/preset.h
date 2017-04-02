#ifndef PRESET_H
#define PRESET_H

#define IDEAL_TEMP        0
#define MIN_TEMP          1
#define MAX_TEMP          2
#define IDEAL_LIGHT       3
#define MIN_LIGHT         4

#define NUM_IDS           3

struct dict {
  String id;
  int presets[5];
};
typedef struct dict dict;

dict data[NUM_IDS] = {
  {.id = "13 2e 3a", .presets = {15, 10, 20, 50, 30}}, 
  {.id = "e3 e5 68", .presets = {24, 20, 30, 80, 60}},
  {.id = "f4 64 5f", .presets = {30, 20, 40, 30, 10}}};
//int data[6] = {24, 20, 30, 80, 60, 100};

#endif
