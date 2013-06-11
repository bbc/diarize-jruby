# diarize-jruby
# 
# Copyright (c) 2013 British Broadcasting Corporation
# 
# Licensed under the GNU Affero General Public License version 3 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.gnu.org/licenses/agpl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'helper'

class TestSuperVector < Test::Unit::TestCase

  def test_generate_from_model
    model = Diarize::Speaker.load_model(File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm'))
    sv = Diarize::SuperVector.generate_from_model(model)
    assert_equal 512 * 24, sv.dim
    # Checking all elements are OK
    model.nb_of_components.times do |i|
      gaussian = model.components.get(i)
      gaussian.dim.times do |j|
        assert_equal gaussian.mean(j), sv.vector[i * gaussian.dim + j]
      end
    end
  end

  def test_hash
    model = Diarize::Speaker.load_model(File.join(File.dirname(__FILE__), 'data', 'speaker1.gmm'))
    sv = Diarize::SuperVector.generate_from_model(model)
    assert_equal sv.vector.hash, sv.hash
  end

end
