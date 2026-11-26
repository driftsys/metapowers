"""Card charges."""


def charge(customer_id, amount_cents, currency="EUR"):
    if amount_cents <= 0:
        raise ValueError("amount must be positive")
    return {"customer": customer_id, "amount": amount_cents, "currency": currency}
