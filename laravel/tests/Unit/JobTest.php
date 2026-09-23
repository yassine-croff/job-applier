<?php

namespace Tests\Unit;

use App\Models\Job;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class JobTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_has_fillable_fields()
    {
        $job = new Job();
        $this->assertEquals([
            'source',
            'title',
            'company',
            'description',
            'requirements',
            'url',
            'salary',
            'dedup_hash',
            'discovered_at',
        ], $job->getFillable());
    }

    /** @test */
    public function it_casts_dates_correctly()
    {
        $job = new Job();
        $this->assertEquals('datetime', $job->getCasts()['discovered_at']);
        $this->assertEquals('datetime', $job->getCasts()['created_at']);
        $this->assertEquals('datetime', $job->getCasts()['updated_at']);
    }

    /** @test */
    public function it_generates_dedup_hash_on_creating_if_not_present()
    {
        $job = Job::create([
            'source' => 'linkedin',
            'title' => 'Software Engineer',
            'company' => 'Tech Corp',
            'description' => 'A great job',
            'url' => 'https://example.com/job/1',
            'discovered_at' => now(),
        ]);

        $this->assertNotNull($job->dedup_hash);
        $this->assertEquals(
            hash('sha256', 'Tech CorpSoftware EngineerA great job'),
            $job->dedup_hash
        );
    }

    /** @test */
    public function it_regenerates_dedup_hash_when_company_title_or_description_changed()
    {
        $job = Job::create([
            'source' => 'linkedin',
            'title' => 'Software Engineer',
            'company' => 'Tech Corp',
            'description' => 'A great job',
            'url' => 'https://example.com/job/1',
            'discovered_at' => now(),
        ]);

        $originalHash = $job->dedup_hash;

        // Change company
        $job->company = 'New Corp';
        $job->save();

        $this->assertNotEquals($originalHash, $job->dedup_hash);
        $this->assertEquals(
            hash('sha256', 'New CorpSoftware EngineerA great job'),
            $job->dedup_hash
        );

        // Change title
        $job->title = 'Senior Software Engineer';
        $job->save();

        $this->assertNotEquals($originalHash, $job->dedup_hash);
        $this->assertEquals(
            hash('sha256', 'New CorpSenior Software EngineerA great job'),
            $job->dedup_hash
        );

        // Change description
        $job->description = 'An amazing job opportunity';
        $job->save();

        $this->assertNotEquals($originalHash, $job->dedup_hash);
        $this->assertEquals(
            hash('sha256', 'New CorpSenior Software EngineerAn amazing job opportunity'),
            $job->dedup_hash
        );
    }

    /** @test */
    public function it_does_not_change_dedup_hash_when_other_fields_changed()
    {
        $job = Job::create([
            'source' => 'linkedin',
            'title' => 'Software Engineer',
            'company' => 'Tech Corp',
            'description' => 'A great job',
            'url' => 'https://example.com/job/1',
            'discovered_at' => now(),
        ]);

        $originalHash = $job->dedup_hash;

        // Change URL (should not affect dedup_hash)
        $job->url = 'https://example.com/job/2';
        $job->save();

        $this->assertEquals($originalHash, $job->dedup_hash);

        // Change salary (should not affect dedup_hash)
        $job->salary = '$100,000+';
        $job->save();

        $this->assertEquals($originalHash, $job->dedup_hash);

        // Change source (should not affect dedup_hash)
        $job->source = 'indeed';
        $job->save();

        $this->assertEquals($originalHash, $job->dedup_hash);
    }
}