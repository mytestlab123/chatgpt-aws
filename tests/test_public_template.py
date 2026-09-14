import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts.check_aws_target import validate
from scripts.check_repository import entrypoint_errors, text_errors, workflow_errors
from scripts.site_tools import check_site, marker_matches, prepare, verify_live

SHA = 'a' * 40
REPO = 'owner/lab'


class PublicSafetyTests(unittest.TestCase):
    def test_account_id_alone_is_not_a_secret(self):
        self.assertEqual(text_errors('notes', '123456789012'), [])

    def test_credential_patterns_do_not_echo_secret(self):
        values = ['AKIA' + 'A' * 16, 'ghp_' + 'a' * 36,
                  'github_pat_' + 'a' * 60, '-----BEGIN ' + 'PRIVATE KEY-----',
                  'aws_secret_access_key=' + 'x' * 40]
        for value in values:
            with self.subTest(value=value[:4]):
                errors = text_errors('fixture', value)
                self.assertTrue(errors)
                self.assertNotIn(value, str(errors))

    def test_public_entrypoints_reject_old_private_status(self):
        self.assertTrue(entrypoint_errors('README.md', 'The source repository currently remains private.'))
        self.assertTrue(entrypoint_errors('CONTEXT.md', '`mytestlab123/chatgpt-aws` is private and active.'))

    def test_public_entrypoints_accept_public_status(self):
        self.assertEqual(entrypoint_errors('README.md', 'This repository is public and active.'), [])
        self.assertEqual(entrypoint_errors('docs/index.md', 'Public primary reference repository.'), [])

    def test_non_entrypoint_history_can_describe_private_pattern(self):
        self.assertEqual(entrypoint_errors('docs/learning/publishing-model.md', 'while this repository is private'), [])

    def test_pr_cannot_request_global_oidc(self):
        errors = workflow_errors('bad', 'on: [pull_request]\npermissions: {contents: read, id-token: write}\njobs: {}\n')
        self.assertTrue(errors)

    def test_reject_privileged_event(self):
        self.assertTrue(workflow_errors('bad', 'on: {pull_request_target: {}}\npermissions: {contents: read}\njobs: {}\n'))

    def test_reject_unpinned_action(self):
        self.assertTrue(workflow_errors('bad', 'on: {pull_request: {}}\npermissions: {contents: read}\njobs:\n  build:\n    steps:\n      - uses: actions/checkout@v4\n'))

    def test_reject_aws_without_main_guard(self):
        text = 'on: {workflow_dispatch: {}}\npermissions: {contents: read}\njobs:\n  aws:\n    steps:\n      - uses: aws-actions/configure-aws-credentials@' + 'a' * 40 + '\n'
        self.assertTrue(workflow_errors('bad', text))

    def test_oidc_free_pr_is_valid(self):
        self.assertEqual(workflow_errors('ok', 'on: {pull_request: {}}\npermissions: {contents: read}\njobs: {}\n'), [])


class TargetTests(unittest.TestCase):
    def setUp(self):
        self.env = dict(GITHUB_EVENT_NAME='workflow_dispatch', GITHUB_REF='refs/heads/main',
                        GITHUB_REPOSITORY=REPO, AWS_EXECUTION_REPOSITORY=REPO,
                        AWS_LABS_ENABLED='true', AWS_REGION='ap-southeast-1',
                        AWS_ALLOWED_ACCOUNT_ID='123456789012', AWS_ROLE_ARN='arn:aws:iam::123456789012:role/lab')

    def test_valid_explicit_target(self):
        self.assertEqual(validate(self.env), [])

    def test_invalid_binding_each_fails(self):
        for key in self.env:
            with self.subTest(key=key):
                changed = dict(self.env)
                changed[key] = ''
                self.assertTrue(validate(changed))

    def test_other_role_account_fails(self):
        self.env['AWS_ROLE_ARN'] = 'arn:aws:iam::999999999999:role/lab'
        self.assertTrue(validate(self.env))

    def test_pr_and_feature_dispatch_fail(self):
        for key, value in [('GITHUB_EVENT_NAME', 'pull_request'), ('GITHUB_REF', 'refs/heads/feature')]:
            changed = dict(self.env)
            changed[key] = value
            self.assertTrue(validate(changed))


class SiteTests(unittest.TestCase):
    def test_prepare_is_deterministic_and_copies_canonical_prompt(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'docs').mkdir()
            (root / 'PROMPT.md').write_text('# Bootstrap\n')
            prepare(root, SHA, REPO)
            first = (root / 'docs/build-info.json').read_bytes()
            prepare(root, SHA, REPO)
            self.assertEqual(first, (root / 'docs/build-info.json').read_bytes())
            self.assertEqual((root / 'PROMPT.md').read_bytes(), (root / 'docs/downloads/PROMPT.md').read_bytes())
            self.assertEqual((root / 'PROMPT.md').read_bytes(), (root / 'docs/PROMPT.md').read_bytes())

    def test_invalid_sha_is_rejected(self):
        with self.assertRaises(ValueError):
            prepare(Path('.'), 'main', REPO)

    def test_missing_site_outputs_fail(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assertTrue(check_site(Path(directory), 'https://example.test/project/'))

    def test_stale_manifest_is_not_success(self):
        self.assertFalse(marker_matches({'source_sha': 'b' * 40, 'repository': REPO}, SHA, REPO))
        self.assertFalse(marker_matches({'source_sha': SHA, 'repository': 'wrong/repo'}, SHA, REPO))
        self.assertFalse(marker_matches([], SHA, REPO))

    def test_live_200_with_old_commit_fails(self):
        with patch('scripts.site_tools.get', return_value=json.dumps({'source_sha': 'b' * 40, 'repository': REPO}).encode()):
            with self.assertRaises(RuntimeError):
                verify_live('https://example.test/project/', SHA, REPO, attempts=1, delay=0)

    def test_live_exact_commit_passes(self):
        def fake_get(url):
            if 'build-info.json' in url:
                return json.dumps({'source_sha': SHA, 'repository': REPO}).encode()
            if 'search_index.json' in url:
                return json.dumps({'docs': [
                    {'location': 'PROMPT.html'},
                    {'location': 'PUBLIC_TEMPLATE_SECURITY.html'},
                ]}).encode()
            return b'page content'
        with patch('scripts.site_tools.get', side_effect=fake_get):
            verify_live('https://example.test/project/', SHA, REPO, attempts=1, delay=0)


if __name__ == '__main__':
    unittest.main()
