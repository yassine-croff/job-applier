<?php

namespace Tests\Feature;

use App\Models\Job;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class JobTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_can_create_a_job_with_all_required_fields()
    {
        $job = Job::create([
            'source' => 'linkedin',
            'title' => 'Software Engineer',
            'company' => 'Tech Corp',
            'description' => 'A great job',
            'requirements' => 'PHP, Laravel, MySQL',
            'url' => 'https://example.com/job/1',
            'salary' => '$80,000 - $100,000',
            'discovered_at' => now(),
        ]);

        $this->assertDatabaseHas('job_listings', [
            'id' => $job->id,
            'source' => 'linkedin',
            'title' => 'Software Engineer',
            'company' => 'Tech Corp',
            'description' => 'A great job',
            'requirements' => 'PHP, Laravel, MySQL',
            'url' => 'https://example.com/job/1',
            'salary' => '$80,000 - $100,000',
        ]);

        $this->assertNotNull($job->dedup_hash);
        $this->assertEquals(
            hash('sha256', 'Tech CorpSoftware EngineerA great job'),
            $job->dedup_hash
        );
    }

    /** @test */
    public function it_enforces_unique_url_constraint()
    {
        Job::create([
            'source' => 'linkedin',
            'title' => 'Software Engineer',
            'company' => 'Tech Corp',
            'description' => 'A great job',
            'url' => 'https://example.com/job/1',
            'discovered_at' => now(),
        ]);

        $this->expectException(\Illuminate\Database\QueryException::class);
        Job::create([
            'source' => 'indeed',
            'title' => 'Product Manager',
            'company' => 'Biz Inc',
            'description' => 'Another great job',
            'url' => 'https://example.com/job/1', // Duplicate URL
            'discovered_at' => now(),
        ]);
    }

    /** @test */
    public function it_enforces_unique_dedup_hash_constraint()
    {
        Job::create([
            'source' => 'linkedin',
            'title' => 'Software Engineer',
            'company' => 'Tech Corp',
            'description' => 'A great job',
            'url' => 'https://example.com/job/1',
            'discovered_at' => now(),
        ]);

        $this->expectException(\Illuminate\Database\QueryException::class);
        Job::create([
            'source' => 'indeed',
            'title' => 'Software Engineer', // Same title
            'company' => 'Tech Corp', // Same company
            'description' => 'A great job', // Same description
            'url' => 'https://example.com/job/2', // Different URL but same dedup_hash
            'discovered_at' => now(),
        ]);
    }

    /** @test */
    public function it_allows_nullable_description_and_requirements()
    {
        $job = Job::create([
            'source' => 'linkedin',
            'title' => 'Software Engineer',
            'company' => 'Tech Corp',
            'description' => null,
            'requirements' => null,
            'url' => 'https://example.com/job/1',
            'salary' => null,
            'discovered_at' => now(),
        ]);

        $this->assertNull($job->description);
        $this->assertNull($job->requirements);
        $this->assertNull($job->salary);
        $this->assertNotNull($job->dedup_hash);
        $this->assertEquals(
            hash('sha256', 'Tech CorpSoftware Engineer'),
            $job->dedup_hash
        );
    }

    /** @test */
    public function it_orders_by_discovered_at_descending_by_default()
    {
        $oldJob = Job::create([
            'source' => 'linkedin',
            'title' => 'Old Job',
            'company' => 'Old Corp',
            'description' => 'An old job',
            'url' => 'https://example.com/job/old',
            'discovered_at' => now()->subDays(2),
        ]);

        $newJob = Job::create([
            'source' => 'indeed',
            'title' => 'New Job',
            'company' => 'New Corp',
            'description' => 'A new job',
            'url' => 'https://example.com/job/new',
            'discovered_at' => now(),
        ]);

        $jobs = Job::all();
        $this->assertEquals($oldJob->id, $jobs->first()->id);
        $this->assertEquals($newJob->id, $jobs->last()->id);
    }
}