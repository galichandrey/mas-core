#!/usr/bin/env python3
"""
JSON Schema Validator
Validates JSON files against schemas with detailed error reporting
"""

import json
import sys
from jsonschema import validate, ValidationError

def validate_json(json_file, schema_file):
    """
    Validate JSON against schema
    Returns: (success, errors_list)
    """
    try:
        with open(json_file, 'r') as f:
            data = json.load(f)

        with open(schema_file, 'r') as f:
            schema = json.load(f)

        validate(instance=data, schema=schema)
        return True, []

    except ValidationError as e:
        return False, [{
            'message': e.message,
            'path': list(e.path),
            'schema_path': list(e.schema_path)
        }]
    except Exception as e:
        return False, [{'message': str(e), 'path': [], 'schema_path': []}]

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: validate.py <json_file> <schema_file>")
        sys.exit(1)

    success, errors = validate_json(sys.argv[1], sys.argv[2])

    if success:
        print("✓ Validation passed")
        sys.exit(0)
    else:
        print("✗ Validation failed:")
        for error in errors:
            print(f"  - {error['message']}")
            if error['path']:
                print(f"    Path: {'.'.join(map(str, error['path']))}")
        sys.exit(1)