#--
# Copyright (c) 2006 James Adam
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
#
# = IN OTHER WORDS:
#
# You are free to use this software as you please, but if it breaks you'd
# best not come a'cryin...
#++

# Load the engines & bundles extensions
require 'engines'
require 'bundles'

module ::Engines::Version
  Major = 1 # change implies compatibility breaking with previous versions
  Minor = 1 # change implies backwards-compatible change to API
  Release = 4 # incremented with bug-fixes, updates, etc.
end

#--
# Create the Engines directory if it isn't present
#++
if !File.exist?(Engines.config(:root))
  Engines.log.debug "Creating engines directory in /vendor"
  FileUtils.mkdir_p(Engines.config(:root))
end

# Keep a hold of the Rails Configuration object
Engines.rails_config = config

# Initialize the routing (controller_paths)
Engines.initialize_routing