<?php

namespace Database\Factories;

use App\Models\Job;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Job>
 */
class JobFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = Job::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $title = $this->faker->jobTitle;
        $company = $this->faker->company;
        $description = $this->faker->paragraphs(3, true);
        $stringForHash = $company . $title . $description;

        return [
            'source' => $this->faker->randomElement(['linkedin', 'indeed', 'glassdoor', 'ziprecruiter']),
            'title' => $title,
            'company' => $company,
            'description' => $description,
            'requirements' => $this->faker->paragraphs(2, true),
            'url' => $this->faker->unique()->url,
            'salary' => $this->faker->randomElement([null, '$50,000 - $70,000', '$80,000 - $100,000', '$100,000+']),
            'dedup_hash' => hash('sha256', $stringForHash),
            'discovered_at' => $this->faker->dateTimeBetween('-1 year', 'now'),
        ];
    }
}