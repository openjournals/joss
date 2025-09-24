# ORCID Integration for JOSS Reviewers

This document describes the ORCID integration implemented to address GitHub issues [#813](https://github.com/openjournals/joss/issues/813) and [#624](https://github.com/openjournals/joss/issues/624).

## Overview

JOSS now supports posting review activities to reviewers' ORCID profiles when papers are accepted. This integration uses the existing ORCID OAuth flow to automatically update reviewers' ORCID profiles with:

1. **Reviews as peer review activities** for reviewers who have authenticated with ORCID

## Implementation Details

### Database Changes

- **New `reviewers` table**: Stores reviewer information linked to existing users
- **Migration**: `20250101000001_create_reviewers.rb` creates the reviewers table
- **User association**: Reviewers are linked to existing User records for ORCID authentication

### Models

- **`Reviewer` model**: Manages reviewer profiles linked to User records
- **`OrcidService`**: Handles API communication using reviewer's personal OAuth tokens
- **`Paper` model**: Updated to trigger ORCID posting when papers are accepted

### Controllers and Views

- **`ReviewersController`**: Admin interface for managing reviewer profiles
- **Views**: Complete CRUD interface for reviewer management

### Configuration

The ORCID integration uses the existing ORCID OAuth configuration:

```bash
# Existing ORCID OAuth credentials (already configured)
ORCID_KEY=your_client_id
ORCID_SECRET=your_client_secret
```

### How It Works

1. **Reviewers authenticate with ORCID** using the existing OAuth flow (same as authors/editors)
2. **Reviewers are linked to User records** that store their OAuth tokens
3. **When papers are accepted**, the system uses each reviewer's personal OAuth token to post review activities to their ORCID profile
4. **No additional API credentials needed** - uses the existing ORCID OAuth setup

## Usage

### Managing Reviewers

1. **Admin access**: Only admins can create/edit reviewer profiles
2. **Navigation**: `/reviewers` - View all reviewers
3. **Linking to ORCID users**: Connect reviewer profiles to existing users who have ORCID authentication

### Automatic ORCID Posting

When a paper is accepted:

1. **Reviewer activities**: Posted to reviewers' ORCID profiles (if they have ORCID authentication and are linked to a User record)

### Rake Tasks

```bash
# Create reviewer records from existing papers
rails reviewers:populate_from_papers

# List reviewers without ORCID authentication
rails reviewers:list_without_orcid

# Link reviewers to existing ORCID-authenticated users
rails reviewers:link_to_orcid_users
```

## Data Posted to ORCID

### Peer Reviews (for reviewers)
- Review role (reviewer)
- Review URL (GitHub issue)
- Review completion date
- Subject paper information (title, DOI, etc.)
- Journal information

## Security and Privacy

- **Production only**: ORCID posting only occurs in production environment
- **Personal OAuth tokens**: Uses each reviewer's personal OAuth token (not global tokens)
- **Optional**: Reviewers can choose not to authenticate with ORCID
- **Graceful failure**: Errors in ORCID posting don't prevent paper acceptance

## Future Enhancements

1. **Batch processing**: Handle ORCID posting failures with retry logic
2. **Notifications**: Email reviewers when reviews are posted to their ORCID profiles
3. **Analytics**: Track ORCID posting success rates
4. **Reviewer onboarding**: Streamlined process for reviewers to add ORCID IDs

## Testing

The integration includes:

- **Unit tests**: For models and services
- **Integration tests**: For ORCID API communication
- **Feature tests**: For reviewer management interface

## Troubleshooting

### Common Issues

1. **Reviewers not linked**: Ensure reviewers are linked to User records with ORCID authentication
2. **Missing OAuth tokens**: Check that users have valid `oauth_token` values
3. **Authentication scope**: Ensure ORCID OAuth has proper scopes for posting data

### Logs

ORCID API errors are logged for debugging. Check Rails logs for:
- Authentication failures
- API rate limiting
- Invalid data format errors

## Related Issues

- [#813](https://github.com/openjournals/joss/issues/813): Update ORCID with reviews (and papers)
- [#624](https://github.com/openjournals/joss/issues/624): Reviewers acknowledge in JOSS
