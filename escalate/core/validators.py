from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _,
import json

class ValValidator:
    """
    Class to handle validation of val custom type
    """
    message = _('Invalid data')
    code = 'invalid'

    def __init__(self, message=None, code=None, whitelist=None):
        if message is not None:
            self.message = message
        if code is not None:
            self.code = code
        if whitelist is not None:
            self.domain_whitelist = whitelist

    def __call__(self, value):
         

        if not value or '@' not in value:
            raise ValidationError(self.message, code=self.code)

        user_part, domain_part = value.rsplit('@', 1)

        if not self.user_regex.match(user_part):
            raise ValidationError(self.message, code=self.code)

        if (domain_part not in self.domain_whitelist and
                not self.validate_domain_part(domain_part)):
            # Try for possible IDN domain-part
            try:
                domain_part = domain_part.encode('idna').decode('ascii')
            except UnicodeError:
                pass
            else:
                if self.validate_domain_part(domain_part):
                    return
            raise ValidationError(self.message, code=self.code)