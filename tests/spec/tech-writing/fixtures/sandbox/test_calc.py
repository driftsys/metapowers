from calc import add


def test_add():
    assert add(2, 3) == 5


def test_round():
    assert add(1.114, 1.115, round_to=2) == 2.23


if __name__ == "__main__":
    test_add()
    test_round()
    print("ok")
