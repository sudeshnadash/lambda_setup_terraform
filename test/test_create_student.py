import os
import sys
import unittest

sys.path.append(f"{os.getcwd()}/src")
sys.path.append(f"{os.getcwd()}/layer/python")

class UnitTesting(unittest.TestCase):
    def test_create_student(self):
        from create_student import lambda_handler
        response = lambda_handler()
        assert response == "Sudeshna Dash"

if __name__ == "__main__":
    unittest.main()