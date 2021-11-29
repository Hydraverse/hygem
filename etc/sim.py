"""HydraGem price action simulator.
"""
__balance = int(0 * 10**6)
__supply_gem = 0
__supply_block = 0
__supply_magic = 0
_mintCost = 1 * 10**6


def _value(add=0):
    balance = __balance + add
    supply = 1 + ((__supply_gem + __supply_block) >> 1)

    if balance == 0:
        return 0

    return (balance << 128) // (supply << 128)


def _cost(payment=0):
    value_ = _value(payment)

    b = __supply_block
    g = __supply_gem

    value_ <<= 127; b <<= 128; g <<= 128

    value_ = (value_ - ((1 + value_ * b) // (1 + b + g))) >> 128

    return _mintCost if value_ < _mintCost else value_;


def _price():
    value_ = _value(_mintCost * 2)
    cost_ = _cost(_mintCost)

    if value_ < cost_:
        return cost_

    return value_ - cost_


def mint(payment=None):
    global __balance
    global __supply_gem
    global __supply_magic
    global __supply_block

    cost_ = _cost()
    value_ = _value()
    price_ = _price()

    print_cvp("mint: ", cost_, value_, price_)

    if payment is None:
        payment = cost_

    __supply_magic += 1
    __supply_block += 1
    __supply_gem += 1
    __balance += payment

    cost_ = _cost()
    value_ = _value()
    price_ = _price()

    print_cvp("mint: ", cost_, value_, price_)


def buy(payment=None):
    global __balance
    global __supply_gem
    global __supply_block

    cost_ = _cost()
    value_ = _value()
    price_ = _price()

    print_cvp("buy:  ", cost_, value_, price_)

    if payment is None:
        payment = price_

    __balance += payment

    cost_ = _cost()
    value_ = _value()
    price_ = _price()

    print_cvp("buy:  ", cost_, value_, price_)


def burn_block():
    global __balance
    global __supply_gem
    global __supply_magic
    global __supply_block

    cost_ = _cost()
    value_ = _value()
    price_ = _price()

    print_cvp("burnb:", cost_, value_, price_)

    __supply_magic -= 1
    __supply_block -= 1

    cost_ = _cost()
    value_ = _value()
    price_ = _price()

    print_cvp("burnb:", cost_, value_, price_)


def burn_gem():
    global __balance
    global __supply_gem

    cost_ = _cost()
    value_ = _value()
    price_ = _price()

    print_cvp("burng:", cost_, value_, price_)

    __supply_gem -= 1

    __balance -= value_

    cost_ = _cost()
    value_ = _value()
    price_ = _price()

    print_cvp("burng:", cost_, value_, price_)


def print_cvp(name, cost_, value_, price_):
    print(name, f"{str(cost_ / 10**6).ljust(16)}{str(value_ / 10**6).ljust(16)}{str(price_ / 10**6).ljust(16)}")


print_cvp("init:", _cost(), _value(), _price())
