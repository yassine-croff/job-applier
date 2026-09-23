<?php

namespace App\Contracts;

use Illuminate\Support\Collection;

/**
 * Interface for job scrapers to implement.
 */
interface JobSourceAdapter
{
    /**
     * Scrape jobs from the source and return normalized Job instances.
     *
     * @return Collection<int, \App\Models\Job>
     */
    public function scrape(): Collection;

    /**
     * Get the source identifier for this adapter.
     *
     * @return string
     */
    public function getSource(): string;
}