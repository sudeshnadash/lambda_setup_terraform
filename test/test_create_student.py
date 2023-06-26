import os
import sys
import unittest
import pytest
from dataclasses import dataclass

sys.path.append(f"{os.getcwd()}/src")
sys.path.append(f"{os.getcwd()}/layer/python")

@pytest.fixture
def lambda_context():
    @dataclass
    class LambdaContext:
        function_name: str = "create_student"
        memory_limit_in_mb: int = 128
        invoked_function_arn: str = (
            "arn:aws:lambda:us-east-1:8093313241:create_student:lambda_handler"
        )
        aws_request_id: str = "7978979872-27879-22"
    return LambdaContext

class UnitTesting(unittest.TestCase):
    def test_create_student(lambda_context):
        from create_student import lambda_handler
        event = {}
        response = lambda_handler(event, lambda_context)
        assert response == "Sudeshna Dash"

if __name__ == "__main__":
    unittest.main()