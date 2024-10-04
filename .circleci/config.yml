version: 2.1
setup: true

orbs:
  continuation: circleci/continuation@1

jobs:
  setup:
    resource_class: small

    docker:
      - image: cimg/python:3.12

    steps:
      - checkout

      - run:
          name: Install `jinja2`
          command: pip install jinja2

      - run:
          name: Generate config
          command: scripts/circleci_config.py < .circleci/generated_config.yml.j2 > .circleci/generated_config.yml

      - continuation/continue:
          configuration_path: .circleci/generated_config.yml

workflows:
  setup-workflow:
    jobs:
      - setup
