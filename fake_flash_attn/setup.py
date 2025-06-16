from setuptools import setup, find_packages

setup(
    name="fake_flash_attn",
    version="0.1.0",
    packages=find_packages(),
    install_requires=["torch"],
)
