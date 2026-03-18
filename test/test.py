# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


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

    # Write seed
    dut.ui_in.value = 20

    # Do reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # See seed and initial test logic
    print(f"uo_out: {dut.uo_out.value}, uio_out: {dut.uio_out.value}")
    assert dut.uo_out.value == 20
    assert dut.uio_out.value == 20

    await ClockCycles(dut.clk, 1)

    print(f"uo_out: {dut.uo_out.value}, uio_out: {dut.uio_out.value}")
    assert dut.uo_out.value == 21
    assert dut.uio_out.value == 21
