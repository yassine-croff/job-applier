<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('job_listings', function (Blueprint $table) {
            $table->id();
            $table->string('source');
            $table->string('title');
            $table->string('company');
            $table->text('description')->nullable();
            $table->text('requirements')->nullable();
            $table->string('url')->unique();
            $table->string('salary')->nullable();
            $table->string('dedup_hash')->unique();
            $table->timestamp('discovered_at');
            $table->timestamps();

            // Indexes for common queries
            $table->index(['source', 'discovered_at']);
            $table->index('dedup_hash');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('job_listings');
    }
};