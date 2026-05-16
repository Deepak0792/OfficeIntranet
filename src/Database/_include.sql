/*
 * SdxCore Database - Master Include Script
 * 
 * This is the root entry point for all database deployments.
 * It orchestrates the execution of all schema objects in the correct order.
 * 
 * Execution Order:
 *   1. Base/          - Initial schema migration from docs/database/microservices
 *   2. Phase1 Schema changes
 *		1. Sprint01/      - First sprint incremental changes
 *		2. Sprint02/      - Second sprint incremental changes
 *   3. Phase2 Schema changes
 *		1. Sprint01/      - First sprint incremental changes
 *		2. Sprint02/      - Second sprint incremental changes
 *		..... and so on
 *
 * 
 * Each folder contains its own _include.sql that manages its internal structure.
 * 
 * IMPORTANT: This file is executed as a Pre-Deployment script.
 * All schema changes must be idempotent and support incremental deployment.
 */

-- Base: Base Schema Migration
PRINT 'Base: Executing Base Schema Migration...';
:r .\Base\_include.sql
PRINT 'Base: Base Schema Migration Completed';

-- Phase 1: DB Changes
PRINT 'Phase1: Executing Sprint-Based Changes...';
--Start of Delta Sprint
:r .\Phase1\_include.sql
--:r .\Phase2\_include.sql
--End of Delta Sprint