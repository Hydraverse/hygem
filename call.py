#!/usr/bin/env python3
"""Format a smart contract call.
"""
import os
import sys
import argparse
import pprint

CALL_MAP = {
    "allowance(address,address)": "dd62ed3e",
    "balanceOf(address)": "70a08231",
    "burn()": "44df8e70",
    "burned(address)": "a7509b83",
    "buy(address)": "f088d547",
    "decimals()": "313ce567",
    "mint()": "1249c58b",
    "name()": "06fdde03",
    "price()": "a035b1fe",
    "redeem()": "be040fb0",
    "redeem(uint256)": "db006a75",
    "symbol()": "95d89b41",
    "totalSupply()": "18160ddd",
    "transfer(address,uint256)": "a9059cbb",
    "transferFrom(address,address,uint256)": "23b872dd",
    "value()": "3fa4f245"
}


def format_param(param: str):
    return param.rjust(64, "0")


def format_number_param(number: (int, float), decimals: int = 8):
    return format_param(
        hex(
            int(number * 10**decimals) if isinstance(number, float)
            else number
        )[2:]
    )


def format_auto_param(param: (str, int, float)):
    if isinstance(param, (int, float)):
        return format_number_param(param)

    try:
        return format_number_param(
            float(param) if str(1.1)[1] in param
            else int(param)
        )

    except ValueError:
        return format_param(param)


def format_params(*params: (str, int, float)):
    return "".join(format_auto_param(param) for param in params)


def format_call_param(call: str):
    try:
        int(call, 16)
        return call.rjust(8, "0")

    except ValueError:
        return CALL_MAP[call if "(" in call else f"{call}()"]


def format_call(call: str, *params: (str, int, float)):
    return format_call_param(call) + format_params(*params)


class _ListAction(argparse.Action):

    def __init__(self, *args, **kwds):
        super(_ListAction, self).__init__(*args, **kwds, nargs=0)

    def __call__(self, parser, *args, **kwds):
        print(pprint.pformat(CALL_MAP, indent=4).replace("{", "{\n ").replace("}", "\n}\n"))
        parser.exit()


def main():
    parser = argparse.ArgumentParser(prog=os.path.basename(sys.argv[0]), description=__doc__)

    parser.add_argument("-V", "--version", action="version", version="%(prog)s 1.0")

    parser.add_argument("-l", "--list", help="list known functions", action=_ListAction)

    parser.add_argument("call", type=format_call_param, metavar="CALL", help="function address or alias.")

    parser.add_argument("param", type=format_auto_param, nargs="*", metavar="PARAM", help="function param.")

    args = parser.parse_args()

    print(args.call + ("".join(args.param) if len(args.param) else ""))


if __name__ == "__main__":
    main()
