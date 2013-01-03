module Diarize

  class SuperVector

    include JBLAS

    attr_reader :vector

    def initialize(vector)
      @vector = vector
    end

    def self.generate_from_model(model)
      # Generates a supervector from a LIUM GMM
      dim = model.nb_of_components * model.components.get(0).dim
      vector = DoubleMatrix.new(1, dim)
      model.nb_of_components.times do |k|
        gaussian = model.components.get(k)
        gaussian.dim.times do |i|
          vector[k * gaussian.dim + i] = gaussian.mean(i)
        end
      end
      SuperVector.new(vector)
    end

    def self.ubm_gaussian_weights
      # Returns a vector of gaussian weights, same dimension as speaker's super vectors
      @@ubm_gaussian_weights ||= (
        ubm = Speaker.new
        weights = DoubleMatrix.new(1, ubm.supervector.dim)
        ubm.model.nb_of_components.times do |k|
          gaussian = ubm.model.components.get(k)
          gaussian.dim.times do |i|
            weights[k * gaussian.dim + i] = gaussian.weight
          end
        end
        weights
      )
    end

    def self.ubm_covariance
      # Returns a vector of diagonal covariances, same dimension as speaker's super vectors
      @@ubm_covariance ||= (
        ubm = Speaker.new
        cov = DoubleMatrix.new(1, ubm.supervector.dim)
        ubm.model.nb_of_components.times do |k|
          gaussian = ubm.model.components.get(k)
          gaussian.dim.times do |i|
            cov[k * gaussian.dim + i] = gaussian.getCovariance(i, i)
          end
        end
        cov
      )
    end

    def self.divergence(sv1, sv2)
      ubm_gaussian_weights.mul(((sv1.vector - sv2.vector) ** 2) / ubm_covariance).sum
    end

    def dim
      @vector.columns
    end

    def hash
      @vector.hash
    end

  end

end
