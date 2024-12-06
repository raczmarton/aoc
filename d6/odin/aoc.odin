package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:sync"
import "core:sync/chan"
import "core:thread"
import "core:mem"
import "core:mem/virtual"

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

Input :: struct {
    m: [dynamic][dynamic]rune,
    guard: Guard,
    o_x, o_y: int,
    out_chan: ^chan.Chan(bool),
    steps: int,
}


check_loop:: proc(t: thread.Task)  {
    input := cast(^Input)t.data
    m := input.m
    guard := input.guard
    o_x := input.o_x
    o_y := input.o_y
    m[o_x][o_y] = '#'
    g:= guard
    original_steps := input.steps
    steps := 0
    visited := make(map[string]int)
    for true {
        pos := fmt.tprintf("%d,%d", g.row, g.col)
        if steps > original_steps * 2 {
            ok := chan.send(input.out_chan^, true)
            if !ok {
                fmt.println("Failed to send result")
                break
            }
        } // Loop detected
        
        x, y := get_next_pos(g)
        if(x < 0 || x >= len(m) || y < 0 || y >= len(m[0])) {
            break
        }
        if(check_obstacle(m, guard)) {
            g = turn_right(g)
            continue
        }
        visited[pos] += 1 
        steps += 1
        g.row = x
        g.col = y
    }
    send_ok := chan.send(input.out_chan^, false)
    if !send_ok {
        fmt.println("Failed to send result")

        }
}



count_obstruction_positions:: proc(m: [dynamic][dynamic]rune, guard: Guard, steps: int) -> int {
    count := 0
    wg : sync.Wait_Group

    threadPool :thread.Pool
    poolsize := 12
    thread.pool_init(&threadPool, context.allocator, poolsize)
    thread.pool_start(&threadPool)
    
    out_chan, out_err := chan.create(chan.Chan(bool), context.allocator)
    if out_err != os.ERROR_NONE {
        fmt.println("Failed to create output channel")
        return -1
    }
    defer chan.destroy(out_chan)
    defer thread.pool_destroy(&threadPool)
    client_arena :virtual.Arena
    arena_allocator_error := virtual.arena_init_growing(&client_arena, 1 * mem.Byte)
    client_allocator := virtual.arena_allocator(&client_arena)
    poolindex := 0
    for _, i in m {
        for _, j in m[i] {
            if (i == guard.row && j == guard.col) {
                continue // Skip guard's starting position
            }
            m_copy := m
            g_copy := guard
            input := Input{m_copy, g_copy, i, j, &out_chan, steps}
            thread.pool_add_task(&threadPool, client_allocator, check_loop, &input, poolindex % poolsize)
        }
    }
    for thread.pool_num_in_processing(&threadPool) > 0 || chan.len(out_chan) > 0 {
        result, ok := chan.recv(out_chan)
        if !ok {
            fmt.println("Failed to receive result")
            return -1
        }
        fmt.println("Thread pool state", thread.pool_num_in_processing(&threadPool), "out chan state", chan.len(out_chan), "result", count)
        count += result ? 1 : 0
    }
    thread.pool_finish(&threadPool)
    return count
}

part2:: proc(m: [dynamic][dynamic]rune, steps: int) {
    guard := find_guard(m)
    result := count_obstruction_positions(m, guard, steps)
    fmt.println(result)
}

part1:: proc(m: [dynamic][dynamic]rune) -> int {
    posmap := make(map[string]int)
    guard := find_guard(m)
    rows := len(m)
    cols := len(m[0])
    steps := 0
    posmap[fmt.tprintf("%d,%d", guard.row, guard.col)] = 1
    for true {
        x, y := get_next_pos(guard)
        if(x < 0 || x >= rows || y < 0 || y >= cols) {
            break
        }
        if(check_obstacle(m, guard)) {
            guard = turn_right(guard)
            continue
        }
        
        guard.row = x
        guard.col = y
        posmap[fmt.tprintf("%d,%d", guard.row, guard.col)] = 1
        steps += 1
    }
    fmt.println(len(posmap))
    return steps
}

main:: proc() {
    m := read_input("input")
    result := part1(m)
    fmt.println(result)
    part2(m, result)
}
