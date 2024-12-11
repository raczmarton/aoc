from collections import defaultdict


def blink_stones(stones):
    new_stones = []
    for stone in stones:
        if stone == 0:
            new_stones.append(1)
        elif len(str(stone)) % 2 == 0:
            str_stone = str(stone)
            mid = len(str_stone) // 2
            left = int(str_stone[:mid])
            right = int(str_stone[mid:])
            new_stones.extend([left, right])
        else:
            new_stones.append(stone * 2024)
    return new_stones

def read_integers_from_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
        number_strings = content.split()
        numbers = [int(num) for num in number_strings]
    return numbers

def read_stones_to_dict(filename):
    with open(filename) as file:
        input = file.read().splitlines()

    stones = defaultdict(int)
    for stone in input[0].split():
        stone = int(stone)
        stones[stone] += 1

    return stones

def blink_smarter(stones):
    stones_copy = dict(stones)
    for stone, count in stones_copy.items():
        if count == 0: continue
        if stone == 0:
            stones[1] += count
            stones[0] -= count
        elif len(str(stone)) % 2 == 0:
            stone_str = str(stone)
            new_len = int(len(stone_str) / 2)
            stone_1 = int(stone_str[:new_len])
            stone_2 = int(stone_str[new_len:])
            stones[stone_1] += count
            stones[stone_2] += count
            stones[stone] -= count
        else:
            stones[stone * 2024] += count
            stones[stone] -= count
    return stones

initial_stones = read_integers_from_file("input")
for i in range(25):
    initial_stones = blink_stones(initial_stones)
print(len(initial_stones)) 

initial_stones = read_stones_to_dict("input")
for i in range(75):
    initial_stones = blink_smarter(initial_stones)
print(sum(initial_stones.values()))
