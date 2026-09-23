<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Job extends Model
{
    use HasFactory;
    protected $table = "job_listings";

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'source',
        'title',
        'company',
        'description',
        'requirements',
        'url',
        'salary',
        'dedup_hash',
        'discovered_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'discovered_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Boot the model.
     */
    protected static function booted(): void
    {
        static::creating(function ($job) {
            if (empty($job->dedup_hash)) {
                $job->dedup_hash = $job->generateDedupHash();
            }
        });

        static::updating(function ($job) {
            if ($job->isDirty(["company", "title", "description"])) {
                $job->dedup_hash = $job->generateDedupHash();
            }
        });
    }

    /**
     * Generate deduplication hash based on company+title+description.
     *
     * @return string
     */
    public function generateDedupHash(): string
    {
        $string = sprintf(
            '%s%s%s',
            $this->company ?? '',
            $this->title ?? '',
            $this->description ?? ''
        );

        return hash('sha256', $string);
    }
}