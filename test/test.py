# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

def xorshift32(state):
    # Ensure 32-bit integer
    state &= 0xFFFFFFFF
    
    # Algorithm steps
    state ^= (state << 13) & 0xFFFFFFFF
    state ^= (state >> 17) & 0xFFFFFFFF
    state ^= (state << 5) & 0xFFFFFFFF
    
    return state

def high_bits(value):
    return (value >> 24) & 0xFF

def mixed_value(value):
    return (value ^ (value >> 11) ^ (value >> 21)) & 0xFF

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 ms (100 Hz)
    clock = Clock(dut.clk, 10, unit="ms")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1

    dut._log.info("Test project behavior")

    seed = 17
    # Write seed
    dut.ui_in.value = seed

    # Do reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # See seed and initial test logic
    print(f"uo_out: {dut.uo_out.value}, uio_out: {dut.uio_out.value}")
    assert dut.uo_out.value == 0
    assert dut.uio_out.value == mixed_value(seed)

    rng_state = seed
    for i in range(10):
        await ClockCycles(dut.clk, 1)
        rng_state = xorshift32(rng_state)

        print(f"uo_out: {dut.uo_out.value}, uio_out: {dut.uio_out.value}")
        assert dut.uo_out.value == 0
        assert dut.uio_out.value == mixed_value(rng_state)