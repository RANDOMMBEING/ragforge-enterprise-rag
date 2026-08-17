"""Basic tests for the ADV RAG project."""
import pytest


def test_basic_import():
    """Test that the app can be imported."""
    from app.main import app
    assert app is not None


def test_config_import():
    """Test that config can be imported."""
    from app.config import settings
    assert settings is not None
# final sync2
