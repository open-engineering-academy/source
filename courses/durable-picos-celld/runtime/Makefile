.PHONY: test persistence contract unit

test:
	PYTHONPATH=src python -m pytest tests -q

unit:
	PYTHONPATH=src python -m pytest tests/test_pico_unit.py -q

contract:
	PYTHONPATH=src python -m pytest tests/test_runtime_contract.py -q

persistence:
	PYTHONPATH=src python -m pytest tests/test_persistence.py -q
