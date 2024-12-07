package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:sync"
import "core:sync/chan"
import "core:thread"
import "core:mem"
import "core:mem/virtual"
import "core:strconv"

read_input:: proc(path: string) -> [dynamic][dynamic]rune {
    m: [dynamic][dynamic]rune
    file, err := os.open(path)
    if err != os.ERROR_NONE {
        fmt.println(err)
        return nil
    }
    defer os.close(file)
    buf:= make([]u8, 10240000)
    os.read_full(file, buf)
    content := transmute(string)buf[:]
    lines := strings.split(content, "\n")
    for line, i in lines {
        append(&m, make([dynamic]rune))
        for char in line {
            append(&m[i], char)
        }
    }
    return m
}

Guard :: struct {
    row, col: int,
    direction: rune
}

get_next_pos:: proc(guard: Guard) -> (int, int) {
    switch(guard.direction) {
        case '^': return guard.row - 1, guard.col
        case 'v': return guard.row + 1, guard.col
        case '<': return guard.row, guard.col - 1
        case '>': return guard.row, guard.col + 1
    }
    return guard.row, guard.col
}

check_obstacle:: proc(m: [dynamic][dynamic]rune, guard: Guard) -> bool {
    if(guard.row < 1 || guard.row >= len(m) -1 || guard.col < 1 || guard.col >= len(m[0]) -1) {
            return false;
        }
    switch(guard.direction) {
        case '^': return m[guard.row - 1][guard.col] == '#'
        case 'v': return m[guard.row + 1][guard.col] == '#'
        case '<': return m[guard.row][guard.col - 1] == '#'
        case '>': return m[guard.row][guard.col + 1] == '#'
    }
    return false
}

turn_right:: proc(guard: Guard) -> Guard {
    switch(guard.direction) {
        case '^': return Guard{guard.row, guard.col, '>'}
        case 'v': return Guard{guard.row, guard.col, '<'}
        case '<': return Guard{guard.row, guard.col, '^'}
        case '>': return Guard{guard.row, guard.col, 'v'}
    }
    return guard
}


find_guard:: proc(m: [dynamic][dynamic]rune) -> Guard{
    for row, i in m {
        for col, j in row {
            if(col == '^' || col == 'v' || col == '<' || col == '>') {
                return Guard{i, j, col}
            }
        }
    }
    return Guard{0, 0, ' '} // should never happen
}


part2:: proc(m: [dynamic][dynamic]rune, steps: int, posmap: map[string]int) {
    guard := find_guard(m)
    start_x, start_y := guard.row, guard.col
    count := 0
    for entry in posmap {
        strs := strings.split(entry, ",")
        row, _ := strconv.parse_int(strs[0])
        col, _ := strconv.parse_int(strs[1])
        if(start_x == row && start_y == col) {
            continue
        }
        //fmt.println(row, col)
        
        m[row][col] = '#'
        _, curr_steps, isloop := count_unique_positions(m, true, steps)
        if(isloop) {
            count += 1
        }
        m[row][col] = '.'
    }
    fmt.println(count)
}

count_unique_positions:: proc(m: [dynamic][dynamic]rune, part2: bool, previous_steps: int) -> (map[string]int, int, bool) {
    posmap := make(map[string]int)
    guard := find_guard(m)
    rows := len(m)
    cols := len(m[0])
    steps := 0
    posmap[fmt.tprintf("%d,%d,%c", guard.row, guard.col, guard.direction)] = 1
    for true {
        
        if(part2) {
            if(steps > rows * cols) {
                return posmap, steps, true
            }
        }
        if(check_obstacle(m, guard)) {
            guard = turn_right(guard)
            continue
        }
        x, y := get_next_pos(guard)
        if(x < 0 || x >= rows || y < 0 || y >= cols) {
            break
        }
        steps += 1
        guard.row = x
        guard.col = y
        posmap[fmt.tprintf("%d,%d,%c", guard.row, guard.col, guard.direction)] += 1
    }
    return posmap, steps, false
}


main:: proc() {
    m := read_input("input")
    posmap, steps, _ := count_unique_positions(m, false, 0)
    fmt.println(len(posmap))
    part2(m, steps, posmap)
}
