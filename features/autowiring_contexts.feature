Feature: Autowiring contexts

    Background:
        Given a working Symfony application with SymfonyExtension configured
        And a Behat configuration containing:
        """
        default:
            suites:
                default:
                    contexts:
                        - App\Tests\SomeContext
        """

    Scenario: Autowiring a context with a service
        Given a feature file containing:
        """
        Feature:
            Scenario:
                Then the container should be passed
        """
        And a context file "tests/SomeContext.php" containing:
        """
        <?php

        namespace App\Tests;

        use Behat\Behat\Context\Context;
        use Psr\Container\ContainerInterface;

        final class SomeContext implements Context {
            private $container;

            public function __construct(?ContainerInterface $container = null) { $this->container = $container; }

            /** @Then the container should be passed */
            public function containerShouldBePassed(): void
            {
                assert(is_object($this->container));
                assert($this->container instanceof ContainerInterface);
            }
        }
        """
        And a YAML services file containing:
            """
            services:
                _defaults:
                    autowire: true

                App\Tests\SomeContext:
                    public: true
            """
        When I run Behat
        Then it should pass

    Scenario: Autowiring a context with a binding
        Given a feature file containing:
        """
        Feature:
            Scenario:
                Then the passed argument should be "KrzysztofKrawczyk"
        """
        And a context file "tests/SomeContext.php" containing:
        """
        <?php

        namespace App\Tests;

        use Behat\Behat\Context\Context;

        final class SomeContext implements Context {
            private $argument;

            public function __construct(?string $argument = null) { $this->argument = $argument; }

            /** @Then the passed argument should be :expected */
            public function passedArgumentShouldBe(string $expected): void { assert($this->argument === $expected); }
        }
        """
        And a YAML services file containing:
            """
            services:
                _defaults:
                    autowire: true
                    bind:
                        $argument: KrzysztofKrawczyk

                App\Tests\SomeContext:
                    public: true
            """
        When I run Behat
        Then it should pass
